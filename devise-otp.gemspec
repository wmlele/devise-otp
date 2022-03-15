# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'devise-otp/version'

Gem::Specification.new do |gem|
  gem.name          = "devise-otp"
  gem.version       = Devise::Otp::VERSION
  gem.authors       = ["Lele Forzani"]
  gem.email         = ["lele@windmill.it"]
  gem.description   = %q{Time Based OTP/rfc6238 compatible authentication for Devise}
  gem.summary       = %q{Time Based OTP/rfc6238 compatible authentication for Devise}
  gem.homepage      = "http://git.windmill.it/wm/devise-otp"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'rails',  '>= 7.0', '< 7.1'
  gem.add_runtime_dependency 'devise', '>= 4.8.0', '< 4.9.0'
  gem.add_runtime_dependency 'rotp',   '>= 2.0.0'

  gem.add_development_dependency "cuprite"
  gem.add_development_dependency "puma"
  gem.add_development_dependency "sqlite3"
end
