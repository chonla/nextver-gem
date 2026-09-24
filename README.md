# nextver (Ruby gem)

Evaluate next version number with SemVer format based on [conventional commit](https://www.conventionalcommits.org/) messages. Ruby port of [chonla/nextver](https://github.com/chonla/nextver). Requires `git` on `PATH`.

## Installation

```ruby
# Gemfile
gem "nextver", require: false, group: :development
```

or `gem install nextver`.

In a Rails app, create `bin/nextver` once and commit it:

```
bin/rails generate nextver:install
```

Outside Rails, `bundle binstubs nextver` does the same.

## Usage

```
bin/nextver [options...] [dir]

  -d  Debug mode, print considering steps.
  -e  Suppress trailing new line. Print only version out.
  -n  Version is not prefixed by v, for example, 1.0.0.
  -t  Show detected latest version.
  -v  Show version of nextver.
```

From Ruby:

```ruby
require "nextver"
Nextver::Repo.new(".").next_version # => "v1.1.0"
```

## Test

```
rake test
```

## License

[MIT](LICENSE.txt)
