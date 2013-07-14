module SuperRole
  class PermissionHierarchyNode
    
    attr_reader :children, :parent, :resource_type, :parent_foreign_key

    def self.find
      
    end

    def initialize(resource_type)
      @resource_type = resource_type
    end

    def add_children
      
    end

    def resource_type
      @resource_type.constantize
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

    def possible_resources_for_owner(owner)
      owner unless parent
      possible_parent_resource_ids = parent.possible_resource_ids_for_owner(owner)
      resource_type.where(parent_foreign_key => possible_parent_resource_ids)
    end

    def possible_resource_ids_for_owner(owner)
      owner.id unless parent
      possible_parent_resource_ids = parent.possible_resource_ids_for_owner(owner_id)
      resource_type.where(parent_foreign_key => possible_parent_resource_ids).pluck(:id)
    end

  end
end