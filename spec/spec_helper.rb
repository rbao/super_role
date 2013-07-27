require 'pry-debugger'
require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

require 'super_role'
Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |file| require file }


# Rspec Config
RSpec.configure do |config|

  
  config.around do |example|
    SuperRole::ActionGroup.destroy_all
    SuperRole::ActionAlias.destroy_all
    SuperRole::PermissionHierarchy.destroy_all

    # Run example in transaction
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
  
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.order = "random"
end