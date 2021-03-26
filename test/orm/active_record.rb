ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)

@schema_migration = ActiveRecord::Base.connection.schema_migration
ActiveRecord::MigrationContext.new(File.expand_path("../../dummy/db/migrate/", __FILE__), @schema_migration).migrate
