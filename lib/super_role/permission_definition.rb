module SuperRole
  class PermissionDefinition

    attr_reader :classes, :defined_permissions

    def initialize(classes)
      @classes = classes
      @defined_permissions = []
    end

    def group(group_name, actions)
      
    end

    def alias_action(alias_names, options)
      
    end

    def actions(actions)
      actions.each do |a|
        define_action(a)
      end

      defined_permission_ids = define_permis
    end

    private
      def define_action(action)
        classes.each do |c|
          defined_permissions << SuperRole.permission_class.find_or_create_by(resource_type: c, action: action)
        end
      end

      def destroy_undefined_permissions
        
      end

  end
end