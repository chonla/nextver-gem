require "open3"
require "nextver/version"

module Nextver
  class Error < StandardError; end

  # Same rules as golang.org/x/mod/semver (major.minor / major-only shorthands allowed).
  SEMVER = /\Av(0|[1-9]\d*)(?:\.(0|[1-9]\d*)(?:\.(0|[1-9]\d*)(?:-([0-9A-Za-z.-]+))?(?:\+[0-9A-Za-z.-]+)?)?)?\z/
  HEADER = /\A\w+(?:\([\w-]+\))?(!)?: .+/
  BREAKING_FOOTER = /^BREAKING[ -]CHANGE(?:: | #)/

  module_function

  # Returns [major, minor, patch, prerelease] or nil when +tag+ isn't a version.
  def parse(tag, prefixed: true)
    m = SEMVER.match(prefixed ? tag : "v#{tag}")
    m && [m[1].to_i, m[2].to_i, m[3].to_i, m[4]]
  end

  # ponytail: prerelease compared as plain string, not per-identifier as SemVer spec says.
  def sort_key(parts)
    parts[0, 3] + (parts[3] ? [0, parts[3]] : [1, ""])
  end

  # :major, :minor, :patch or nil for a single commit message.
  def bump(message)
    header = HEADER.match(message.strip) or return nil
    return :major if header[1] || message.lines.drop(1).any? { |l| l =~ BREAKING_FOOTER }
    { "feat" => :minor, "fix" => :patch }[message[/\A\w+/]]
  end

  class Repo
    def initialize(dir = ".", prefixed: true, log: nil)
      raise Error, "target path is not git repo path" unless File.directory?(File.join(dir, ".git"))
      @dir = dir
      @prefix = prefixed ? "v" : ""
      @prefixed = prefixed
      @log = log || ->(_) {}
    end

    def current_version
      git("tag", "--list").split("\n")
        .select { |t| Nextver.parse(t, prefixed: @prefixed) }
        .max_by { |t| Nextver.sort_key(Nextver.parse(t, prefixed: @prefixed)) }
    end

    def next_version(current = current_version)
      @log.call(@prefixed ? "Version is prefixed by v." : "Version is not prefixed by v.")
      unless current
        @log.call("Current version is missing. Start a new one at v1.0.0.")
        return "#{@prefix}1.0.0"
      end

      @log.call("HEAD commit ID=#{git('rev-parse', 'HEAD').strip}")
      @log.call("Latest tag commit ID=#{git('rev-parse', "#{current}^{commit}").strip}")
      messages = git("log", "--format=%B%x00", "#{current}..HEAD").split("\0").map(&:strip).reject(&:empty?)
      @log.call("#{messages.size} commit(s) since latest tag")

      counts = messages.map { |m| Nextver.bump(m) }.compact.group_by(&:itself).transform_values(&:size)
      @log.call("============\nCommit stats\n------------")
      @log.call("Major change(s) = #{counts.fetch(:major, 0)}")
      @log.call("Minor change(s) = #{counts.fetch(:minor, 0)}")
      @log.call("Revision change(s) = #{counts.fetch(:patch, 0)}")
      @log.call("============")

      major, minor, patch = Nextver.parse(current, prefixed: @prefixed)
      if counts[:major] then major += 1; minor = 0; patch = 0
      elsif counts[:minor] then minor += 1; patch = 0
      elsif counts[:patch] then patch += 1
      else return current
      end
      "#{@prefix}#{major}.#{minor}.#{patch}"
    end

    private

    def git(*args)
      out, err, status = Open3.capture3("git", "-C", @dir, *args)
      raise Error, err.strip unless status.success?
      out
    end
  end
end
