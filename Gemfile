source 'https://rubygems.org'

# Specify your gem's dependencies in devise-otp.gemspec
gemspec

group :test do
  platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter'
  end

  platforms :ruby do
    gem "sqlite3"
  end

  gem "rails", "~> 4.0.0"

  gem "capybara"
  gem 'shoulda'
  gem 'selenium-webdriver'

  #gem 'factory_girl_rails', '~> 1.2'
  #gem 'rspec-rails', '~> 2.6.0'
end