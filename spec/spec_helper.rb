require 'super_role'
require 'support/super_role_config'
require 'support/active_record'
require 'support/mock_models'
require 'pry-debugger'

# Rspec Config
RSpec.configure do |config|

  
  config.around do |example|
    SuperRole::ActionGroup.destroy_all
    SuperRole::ActionAlias.destroy_all
    SuperRole::RoleOwner.destroy_all

    # Run example in transaction
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
  
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.order = "random"
end