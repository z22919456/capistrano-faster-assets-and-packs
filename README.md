# Capistrano::FasterAssets

This gem speeds up asset compilation by skipping the assets:precompile task if none of the assets were changed since last release.

**Feature**: Skipping the webpack:compile task if none of the `app/javascript/*` or `yarn.lock` changed since last release.

This Gem is fork form **capistrano-faster-assets** and one of amazing PR of this gem. 
Original Gem was amazing, but unfortunately it was stop maintenance from 5 years ago. So I fork it and push this gem to rubygem.

Original Version: https://github.com/capistrano-plugins/capistrano-faster-assets  
Original PR: https://github.com/AutoUncle/capistrano-faster-assets  

Works *only* with Capistrano 3+.

### Installation

Add this to `Gemfile`:

    group :development do
      gem 'capistrano', '~> 3.1'
      gem 'capistrano-rails', '~> 1.1'
      gem 'capistrano-faster-assets-and-packs', '~> 1.0'
    end

And then:

    $ bundle install

### Setup and usage

#### assets compilation
Add this line to `Capfile`, after `require 'capistrano/rails/assets'`

    require 'capistrano/faster_assets'
    
Configure your asset depedencies in deploy.rb if you need to check additional paths (e.g. if you have some assets in YOUR_APP/engines/YOUR_ENGINE/app/assets). Default paths are:

    set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)

### webpack compilation
Configure your webpack depedencies in deploy.rb if you need to check additional paths. Default paths are:
    set :webpack_dependencies, %w(app/javascript app/yarn.lock)

Configure your webpack source_entry_packs in deploy.rb, if your `source_entry_packs` configuration in config/webpack.yml is not `packs`.
Default is:

    set :webpack_entry_path, 'packs'

### Reference

Original Gem: https://github.com/capistrano-plugins/capistrano-faster-assets  
The PR Version: https://github.com/AutoUncle/capistrano-faster-assets 




