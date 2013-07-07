module SuperRole
  class PermissionDefinition

    include DslNormalizationHelper

    attr_reader :resource_types, :permissions

    def initialize(resource_types)
      @resource_types = resource_types
      @permissions = []
    end

    # Add a action group.
    # @param [String, Symbol] name The action group name.
    # @param [Array<String, Symbol>] actions The actions in the group.
    def action_group(name, actions)
      name = name.to_s
      actions = arrayify_then_stringify_items(actions)

      ActionGroup.create(name, actions, resource_types)
    end

    def action_alias(alias_names, options)
      
    end

    def actions(actions)
      actions.each do |a|
        define_action(a)
      end
    end

    private
      def define_action(action)
        resource_types.each do |rt|
          permissions << SuperRole.permission_class.new(resource_type: rt, action: action)
        end
      end

  end
end