# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'private_gem_server/version'

Gem::Specification.new do |spec|
  spec.name          = 'private-gem-server'
  spec.version       = PrivateGemServer::VERSION
  spec.authors       = ['Neil E. Pearson']
  spec.email         = ['neil@helium.net.au']
  spec.summary       = %q{Private Gem Server base on Geminabox}
  spec.description   = %q{Serve private gems for deployment in cloud environments.}
  spec.homepage      = 'https://github.com/hx/private-gem-server'
  spec.license       = 'MIT'

  spec.files         = Dir['LICENSE*', 'README*', '{lib,bin}/**/*'] & `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'thin', '~> 1.6'
  spec.add_dependency 'geminabox', '~> 0.1'
  spec.add_dependency 'rack-traffic-logger', '~> 0.1'

end
