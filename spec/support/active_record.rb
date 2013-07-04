ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)
ActiveRecord::Migration.verbose = false