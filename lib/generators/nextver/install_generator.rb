require "rails/generators"

module Nextver
  # rails generate nextver:install
  class InstallGenerator < Rails::Generators::Base
    desc "Creates bin/nextver binstub."

    def create_binstub
      create_file "bin/nextver", <<~RUBY
        #!/usr/bin/env ruby
        require "bundler/setup"
        load Gem.bin_path("nextver", "nextver")
      RUBY
      chmod "bin/nextver", 0o755
    end
  end
end
