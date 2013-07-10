module SuperRole
  class PermissionHierarchyNode
    
    attr_accessor :children

    def self.find
      
    end

    def initialize(resource_type)
      
    end

    def permissions
      node_permissions + children_permissions
    end

    def node_permissions
      SuperRole.permission_class.where(resource_type: resource_type)
    end

    def children_permissions
      children.map(&:permissions)
    end

  end
end