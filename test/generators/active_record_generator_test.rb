require "test_helper"
require "rails/generators/test_case"

if DEVISE_ORM == :active_record
  require "generators/active_record/devise_otp_generator"

  class ActiveRecordGeneratorTest < Rails::Generators::TestCase
    tests ActiveRecord::Generators::DeviseOtpGenerator
    destination File.expand_path("../../tmp", __FILE__)
    setup :prepare_destination

    test "use integer column type for otp_time_drift" do
      run_generator %w(user)
      assert_migration "db/migrate/devise_otp_add_to_users.rb", /t.integer   :otp_time_drift/
    end
  end
end
