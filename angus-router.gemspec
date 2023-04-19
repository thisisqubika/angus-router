lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'angus/router/version'

Gem::Specification.new do |spec|
  spec.name                     = 'angus-router'
  spec.version                  = Angus::Router::VERSION
  spec.platform                 = Gem::Platform::RUBY
  spec.authors                  = ['Gianfranco Zas', 'Adrian Gomez']
  spec.summary                  = 'Router for Rack applications.'
  spec.email                    = %w[angus@moove-it.com]
  spec.description              = <<-DESCRIPTION
    Angus-router is a powerful router for your next generation of awesome Rack applications.
    Just throw your shit into angus-router and run away.
  DESCRIPTION
  spec.homepage                 = 'https://github.com/Moove-it/angus-router'
  spec.license                  = 'MIT'

  spec.files                    = Dir.glob('{lib}/**/*')

  spec.required_ruby_version    = '>= 2.7.0'

  spec.add_dependency('rack')

  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec', '~> 2.14')
  spec.add_development_dependency('simplecov', '0.7.1')
  spec.add_development_dependency('simplecov-rcov', '0.2.3')
  spec.add_development_dependency('simplecov-rcov-text', '0.0.2')
  spec.add_development_dependency('ci_reporter')
end
