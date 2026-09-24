require_relative "lib/nextver/version"

Gem::Specification.new do |s|
  s.name        = "nextver"
  s.version     = Nextver::VERSION
  s.summary     = "Evaluate next SemVer version from conventional commit messages."
  s.authors     = ["Chonlasith Jucksriporn"]
  s.email       = ["chonlasith@gmail.com"]
  s.homepage    = "https://github.com/chonla/nextver-gem"
  s.license     = "MIT"
  s.files       = Dir["lib/**/*.rb", "exe/*", "README.md", "LICENSE.txt"]
  s.bindir      = "exe"
  s.executables = ["nextver"]
  s.required_ruby_version = ">= 2.6"
end
