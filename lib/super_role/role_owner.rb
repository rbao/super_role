module SuperRole
  class RoleOwner

    attr_reader :resource_type, :hierarchy_root

    def initialize(resource_type, options = {})
      @resource_type = resource_type.to_s
      @hierarchy_root = PermissionHierarchyNode.new(resource_type, options)
    end

    def hierarchy_root_all_actions
      SuperRole.permission_class.where(resource_type: resource_type).pluck(:action)
    end
    
    def possible_resources_for_permission(action, resource_type)
      node = hierarchy.find_node(resource_type)
      node.possible_resources_for_action(action)
    end

    def owns(resource_type, options = {}, &block)
      hierarchy_root.owns(resource_type, options, &block)
    end
    
  end
end