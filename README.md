# nextver (Ruby gem)

Evaluate next version number with SemVer format based on [conventional commit](https://www.conventionalcommits.org/) messages. Ruby port of [chonla/nextver](https://github.com/chonla/nextver). Requires `git` on `PATH`.

## Installation

```ruby
# Gemfile
gem "nextver", require: false, group: :development
```

or `gem install nextver`.

To get `bin/nextver` created on every `bundle install`, set this once in your app and commit `.bundle/config`:

```
bundle config set --local bin bin
```

Or run `bundle binstubs nextver` once and commit `bin/nextver`.

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
