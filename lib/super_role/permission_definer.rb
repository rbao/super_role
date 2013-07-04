module SuperRole
  class PermissionDefiner

    attr_accessor :definitions

    def self.run(&block)
      definer = new
      definer.instance_eval(&block)
      definer.run_definitions!
      definer.warn_undefined_permissions
    end

    def initialize
      @definitions = []
    end

    def default_permissions
      [:create, :show, :update, :destroy]
    end

    def define_permissions_for(classes, options = {}, &block)
      classes = Array(classes)
      action_list = extract_actions_from_options(options)
      definition = PermissionDefinition.new(classes)
      
      definition.instance_eval do
        actions action_list
        alias_action :new, to: :create if action_list.include?(:create)
        alias_action :edit, to: :update if action_list.include?(:update)
      end

      definition.instance_eval(&block)
      definitions << definition
    end

    def extract_actions_from_options(options)
      extras = Array(options[:extras])
      only = Array(options[:only])
      except = Array(options[:except])

      actions = only.any? ? only : default_actions
      actions = actions - except
      actions
    end

    def run_definitions!
      new_permissions = permissions_defined - existing_permissions
      new_permissions.each do { |p| p.save! }
    end

    def permissions_defined
      permissions = []
      definitions.each do |d|
        permissions += d.permissions
      end
      permissions
    end

    def undefined_permissions
      existing_permissions - permissions_defined
    end

    def warn_undefined_permissions
      puts 'The following permissions does not exist in the definition file but exists in the database.' \
      
      undefined_permissions.each { |p| puts p }
      
      puts 'You probably meant to remove these permissions, however you should make sure that all references' \
           'to them are removed before removing them. After you have removed all reference to them. run' \
           'rake super_role:clean to remove them.'
    end

    def existing_permissions
      SuperRole.permissions_class.all
    end

  end
end