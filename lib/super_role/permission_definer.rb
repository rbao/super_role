module SuperRole
  
  # - This class provides the top level DSL methods for permission definition file.
  # ex. {SuperRole::PermissionDefiner#define_permissions_for define_permission_for}
  #
  # - This class is also responsible for adding, updating the database to make sure
  # the permissions that exist in the database is consistent with the definition
  # file. 
  class PermissionDefiner

    include InputNormalizationHelper

    attr_accessor :definitions

    def self.run(&block)
      definer = new
      definer.instance_eval(&block)
      ActionGroup.all.freeze
      ActionAlias.all.freeze
      
      definer.run_definitions!
      definer.warn_undefined_permissions if definer.undefined_permissions.any?
    end

    def initialize
      @definitions = []
    end

    def default_actions
      ['create', 'show', 'update', 'destroy']
    end

    # @note This is a DSL method used in the permission definition file.
    # Create an instance of SuperRole::PermissionDefinition according
    # to the given block (DSL), then add it to the definitions array
    # for later processing.
    def define_permissions_for(resource_types, options = {}, &block)
      resource_types = arrayify_then_stringify_items(resource_types)
      action_array = extract_actions_from_options(options)
      definition = PermissionDefinition.new(resource_types)
      
      definition.instance_eval do
        actions action_array
        action_alias :new, :create if action_array.include?('create')
        action_alias :edit, :update if action_array.include?('update')
      end

      definition.instance_eval(&block) if block_given?
      definitions << definition
    end

    def extract_actions_from_options(options)
      extra = arrayify_then_stringify_items(options[:extra])
      only = arrayify_then_stringify_items(options[:only])
      except = arrayify_then_stringify_items(options[:except])

      actions = only.any? ? only : default_actions
      actions -= except
      actions += extra
      actions
    end

    def run_definitions!
      new_permissions = defined_permissions - existing_permissions
      new_permissions.each { |p| p.save! }
    end

    def defined_permissions
      permissions = []
      definitions.each do |d|
        permissions += d.permissions
      end
      permissions
    end

    def undefined_permissions
      existing_permissions - defined_permissions
    end

    def warn_undefined_permissions
      puts 'The following permissions does not exist in the definition file but exists in the database.' \
      
      undefined_permissions.each { |p| puts p }
      
      puts 'You probably meant to remove these permissions, however you should make sure that all references' \
           'to them are removed before removing them. After you have removed all reference to them. run' \
           'rake super_role:clean to remove them.'
    end

    def existing_permissions
      SuperRole.permission_class.constantize.all
    end

  end
end