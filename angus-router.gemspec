lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'angus/router/version'

Gem::Specification.new do |spec|
  spec.name            = 'angus-router'
  spec.version         = Angus::Router::VERSION
  spec.platform        = Gem::Platform::RUBY
  spec.authors         = ['Gianfranco Zas']
  spec.summary         = 'Router for Rack applications.'
  spec.email           = %w[angus@moove-it.com]
  spec.description     = <<-DESCRIPTION
    Angus-router is a powerful router for your next generation of awesome Rack applications.
    Just throw your shit into angus-router and run away.
  DESCRIPTION
  spec.homepage      = 'http://mooveit.github.io/angus-router'
  spec.license       = 'MIT'

  spec.files           = Dir.glob('{lib}/**/*')

  spec.add_dependency('rack', '~> 1.5')

  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec', '~> 2.14')
  spec.add_development_dependency('simplecov', '0.7.1')
  spec.add_development_dependency('simplecov-rcov', '0.2.3')
  spec.add_development_dependency('simplecov-rcov-text', '0.0.2')
  spec.add_development_dependency('ci_reporter')
end
