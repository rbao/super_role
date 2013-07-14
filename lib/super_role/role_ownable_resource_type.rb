module SuperRole
  class PermissionHierarchy

    attr_reader :owner_type
    
    def initialize(owner_type)
      @owner_type = owner_type
      @hierarchy_root = SuperRole::PermissionHierarchyNode.new
    end

    def owns?(resource)
      
    end
    
    def foreign_key_for(owner_type)
      
    end

    def possible_resources_for_permission
      node = hierarchy_root.find_children(owner_type)
      node.possible_resources_for_action(action, owner_id)
    end
    
  end
end