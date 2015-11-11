# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rest_api_learning/version'

Gem::Specification.new do |spec|
  spec.name          = "rest_api_learning"
  spec.version       = RestApiLearning::VERSION
  spec.authors       = ["Jonathan Colby"]
  spec.email         = ["jonathan.colby@gmail.com"]
  spec.summary       = %q{Playing around with Sinatra.}
  spec.description   = %q{Learning Sinatra.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
      
  spec.add_runtime_dependency "sinatra"
  spec.add_runtime_dependency "haml", "~> 4"
  spec.add_runtime_dependency "datamapper"
  spec.add_runtime_dependency "warden"
  spec.add_runtime_dependency "sinatra-contrib"
  spec.add_runtime_dependency "bcrypt-ruby"
  spec.add_runtime_dependency "bcrypt"
  spec.add_runtime_dependency 'rack-flash3'
  spec.add_runtime_dependency 'omniauth'
  spec.add_runtime_dependency 'omniauth_crowd'
    
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.8"
  spec.add_development_dependency "shotgun"
  spec.add_development_dependency "dm-sqlite-adapter"
  spec.add_development_dependency "sqlite3"
  
end
