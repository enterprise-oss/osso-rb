# frozen_string_literal: true

require_relative 'lib/osso/version'

Gem::Specification.new do |spec|
  spec.name          = 'osso'
  spec.version       = Osso::VERSION
  spec.authors       = ['Sam Bauch']
  spec.email         = ['sbauch@gmail.com']

  spec.summary       = 'Main functionality for Osso'
  spec.description   = 'This gem includes the main functionality for Osso apps,'
  spec.homepage      = 'https://github.com/enterprise-oss/osso-rb'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')
  spec.license = 'MIT'

  spec.add_runtime_dependency 'activesupport', '>= 6.0.3.2'
  spec.add_runtime_dependency 'jwt'
  spec.add_runtime_dependency 'omniauth-multi-provider'
  spec.add_runtime_dependency 'omniauth-saml'
  spec.add_runtime_dependency 'rack', '>= 2.1.4'
  spec.add_runtime_dependency 'rack-contrib'
  spec.add_runtime_dependency 'rack-oauth2'
  spec.add_runtime_dependency 'rake'
  spec.add_runtime_dependency 'sinatra'
  spec.add_runtime_dependency 'sinatra-activerecord'
  spec.add_runtime_dependency 'sinatra-contrib'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'pry'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {spec}/*`.split("\n")
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
