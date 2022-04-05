ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)

migrations_path = File.expand_path("../../dummy/db/migrate/", __FILE__)

ActiveRecord::MigrationContext.new(migrations_path, ActiveRecord::SchemaMigration).migrate
