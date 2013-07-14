module SuperRole
  class RoleOwner

    attr_reader :hierarchy

    def initialize(resource_type)
      @hierarchy_root = SuperRole::PermissionHierarchyNode.new(resource_type)
    end
    
    def possible_resources_for_permission(action, resource_type)
      node = hierarchy.find_node(resource_type)
      node.possible_resources_for_action(action)
    end
    
  end
end