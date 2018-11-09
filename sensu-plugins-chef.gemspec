lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'date'
require_relative 'lib/sensu-plugins-chef'

Gem::Specification.new do |s|
  s.authors                = ['Sensu Plugins and contributors']
  s.date                   = Date.today.to_s
  s.description            = 'This plugin provides native Chef instrumentation
                              for monitoring, including: report stale nodes,
                              service health, as well as a handler to remove
                              stale Sensu clients'
  s.email                  = '<sensu-users@googlegroups.com>'
  s.executables            = Dir.glob('bin/**/*.rb').map { |file| File.basename(file) }
  s.files                  = Dir.glob('{bin,lib}/**/*') + %w[LICENSE README.md CHANGELOG.md]
  s.homepage               = 'https://github.com/sensu-plugins/sensu-plugins-chef'
  s.license                = 'MIT'
  s.metadata               = { 'maintainer'         => 'sensu-plugin',
                               'development_status' => 'active',
                               'production_status'  => 'unstable - testing recommended',
                               'release_draft'      => 'false',
                               'release_prerelease' => 'false' }
  s.name                   = 'sensu-plugins-chef'
  s.platform               = Gem::Platform::RUBY
  s.post_install_message   = 'You can use the embedded Ruby by setting EMBEDDED_RUBY=true in /etc/default/sensu'
  s.require_paths          = ['lib']
  s.required_ruby_version  = '>= 2.1.0'
  s.summary                = 'Sensu plugins for chef'
  s.test_files             = s.files.grep(%r{^(test|spec|features)/})
  s.version                = SensuPluginsChef::Version::VER_STRING

  s.add_runtime_dependency 'chef', '= 14.7.17'
  if defined?(RUBY_VERSION) && RUBY_VERSION <= '2.1'
    s.add_development_dependency 'buff-ignore', '1.1.1'
    s.add_runtime_dependency 'chef-zero', '~> 4.5.0'
    s.add_runtime_dependency 'ffi-yajl', '~> 2.2.3'
    s.add_runtime_dependency 'net-http-persistent', '~> 2.9'
    s.add_runtime_dependency 'ohai', '~> 8.17.0'
    s.add_runtime_dependency 'rack', '~> 1.6.5'
  end

  s.add_runtime_dependency 'hashie',       ['< 4.0.0', '>= 2.0.2']
  s.add_runtime_dependency 'ridley',       '5.1.0'
  s.add_runtime_dependency 'sensu-plugin', '~> 1.2'
  s.add_runtime_dependency 'varia_model', '0.6'

  s.add_development_dependency 'bundler', '~> 1.12'

  s.add_development_dependency 'codeclimate-test-reporter', '~> 0.4'
  s.add_development_dependency 'github-markup',             '~> 1.3'
  if defined?(RUBY_VERSION) && RUBY_VERSION <= '2.2.2'
    s.add_development_dependency 'nio4r', '~> 1.2'
  end
  s.add_development_dependency 'pry',                       '~> 0.10'
  s.add_development_dependency 'rake',                      '~> 10.5'
  s.add_development_dependency 'redcarpet',                 '~> 3.2'
  s.add_development_dependency 'rspec',                     '~> 3.4'
  s.add_development_dependency 'rubocop',                   '~> 0.51.0'
  s.add_development_dependency 'yard',                      '~> 0.9.11'
end
