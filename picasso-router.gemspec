Gem::Specification.new do |s|

  s.name            = 'picasso-router'
  s.version         = '0.0.1'
  s.platform        = Gem::Platform::RUBY
  s.authors         = ['*sigh*']
  s.summary         = 'Router for Rack applications.'
  s.description     = 'picasso-router is a powerful router for your next generation of awesome Rack applications. Just throw your shit into picasso-router and run away.'

  s.files           = Dir.glob('{lib}/**/*')

  s.add_dependency('rack', '~> 1.5')

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec', '~> 2.14')
  s.add_development_dependency('simplecov', '0.7.1')
  s.add_development_dependency('simplecov-rcov', '0.2.3')
  s.add_development_dependency('simplecov-rcov-text', '0.0.2')
  s.add_development_dependency('ci_reporter')
end
