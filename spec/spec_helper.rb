require 'super_role'
require 'support/super_role_config'
require 'support/active_record'
require 'support/mock_models'





# Rspec Config
RSpec.configure do |config|

  # Run example in transaction
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
  
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.order = "random"
end