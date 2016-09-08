source 'https://rubygems.org'

# Specify your gem's dependencies in devise-otp.gemspec
gemspec

gem "rdoc"

group :test do
  platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter'
  end

  platforms :ruby do
    gem "sqlite3"
  end

  gem "rails", "~> 5.0.0"

  gem "capybara"
  gem 'shoulda'
  gem 'selenium-webdriver'

  gem 'minitest-reporters', '>= 0.5.0'

end
