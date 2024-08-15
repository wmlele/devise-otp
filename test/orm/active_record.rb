ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)

migrations_path = File.expand_path("../../dummy/db/migrate/", __FILE__)

if Rails.version.to_f >= 7.2
  ActiveRecord::MigrationContext.new(migrations_path).migrate
else
  # To support order versions of Rails (pre v7.2)
  ActiveRecord::MigrationContext.new(migrations_path, ActiveRecord::SchemaMigration).migrate
end
