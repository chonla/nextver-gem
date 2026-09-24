require "minitest/autorun"
require "tmpdir"
require "nextver"

class NextverTest < Minitest::Test
  def test_bump
    assert_equal :minor, Nextver.bump("feat(api): add thing")
    assert_equal :patch, Nextver.bump("fix: bug")
    assert_equal :major, Nextver.bump("feat!: drop api")
    assert_equal :major, Nextver.bump("chore(x)!: drop node")
    assert_equal :major, Nextver.bump("refactor: x\n\nbody\n\nBREAKING CHANGE: gone")
    assert_equal :major, Nextver.bump("fix: x\n\nBREAKING-CHANGE: gone")
    assert_nil Nextver.bump("chore: stuff")
    assert_nil Nextver.bump("random text")
  end

  def test_parse_and_sort
    assert_nil Nextver.parse("1.2.3")
    assert_equal [1, 2, 3, nil], Nextver.parse("1.2.3", prefixed: false)
    tags = %w[v1.0.0 v1.10.0 v1.2.0 v1.10.0-rc1 v0.9]
    assert_equal "v1.10.0", tags.max_by { |t| Nextver.sort_key(Nextver.parse(t)) }
  end

  def test_repo
    Dir.mktmpdir do |dir|
      git = ->(*a) { system("git", "-C", dir, *a, out: File::NULL, err: File::NULL) or raise a.inspect }
      git.("init", "-q")
      commit = ->(m) { git.("-c", "user.name=t", "-c", "user.email=t@t", "commit", "-q", "--allow-empty", "-m", m) }
      repo = Nextver::Repo.new(dir)

      commit.("chore: init")
      assert_nil repo.current_version
      assert_equal "v1.0.0", repo.next_version

      git.("tag", "v1.0.0")
      assert_equal "v1.0.0", repo.next_version
      commit.("fix: a")
      assert_equal "v1.0.1", repo.next_version
      commit.("feat: b")
      assert_equal "v1.1.0", repo.next_version
      commit.("feat!: c")
      assert_equal "v2.0.0", repo.next_version
    end
  end
end
