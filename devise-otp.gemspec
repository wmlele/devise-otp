# frozen_string_literal: true

require_relative "lib/devise-otp/version"

Gem::Specification.new do |gem|
  gem.name = "devise-otp"
  gem.version = Devise::OTP::VERSION
  gem.authors = ["Lele Forzani", "Josef Strzibny"]
  gem.email = ["lele@windmill.it", "strzibny@strzibny.name"]
  gem.description = "Time Based OTP/rfc6238 compatible authentication for Devise"
  gem.summary = "Time Based OTP/rfc6238 compatible authentication for Devise"
  gem.homepage = "http://git.windmill.it/wm/devise-otp"

  gem.files = `git ls-files`.split($/)
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "rails", ">= 7.0", "< 7.2"
  gem.add_runtime_dependency "devise", ">= 4.8.0", "< 5.0"
  gem.add_runtime_dependency "rotp", ">= 2.0.0"

  gem.add_development_dependency "capybara"
  gem.add_development_dependency "cuprite"
  gem.add_development_dependency "minitest-reporters", ">= 0.5.0"
  gem.add_development_dependency "puma"
  gem.add_development_dependency "rdoc"
  gem.add_development_dependency "shoulda"
  gem.add_development_dependency "sprockets-rails"
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "standardrb"
end
