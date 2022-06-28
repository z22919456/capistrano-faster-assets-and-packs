lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/faster_assets/version'

Gem::Specification.new do |gem|
  gem.name          = 'capistrano-faster-assets-and-packs'
  gem.version       = Capistrano::FasterAssets::VERSION
  gem.authors       = ['Andrew Thal', 'Ruben Stranders', 'Arthur Li']
  gem.email         = ['athal7@me.com', 'r.stranders@gmail.com', 'z22919456@gmail.com']
  gem.description   = <<-EOF.gsub(/^\s+/, '')
    Speeds up asset compilation by skipping the assets:precompile task if none of the assets were changed since last release.
    And also skiping the webpack:compile task if nonoe of the app/javascript or yarn.lock changed since last release.

    This Gem is fork form *capistrano-faster-assets* and one of amazing PR in this gem

    Original Version: https://github.com/capistrano-plugins/capistrano-faster-assets
    Original PR: https://github.com/AutoUncle/capistrano-faster-assets



    Works *only* with Capistrano 3+.

    Based on https://coderwall.com/p/aridag
  EOF
  gem.summary       = 'Speeds up asset compilation if none of the assets were changed since last release.'
  gem.homepage      = 'https://github.com/z22919456/capistrano-faster-assets-and-packs'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'capistrano', '>= 3.1'
  gem.add_development_dependency 'rake'
end
