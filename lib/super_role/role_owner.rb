module SuperRole
  class RoleOwner

    cattr_reader :all
    @@all = []

    attr_reader :resource_type, :hierarchy_root

    def self.create(resource_type, options = {})
      all << new(resource_type, options)
    end

    def self.find(resource_type)
      resource_type = resource_type.to_s

      all.select { |o| o.resource_type == resource_type }.first
    end

    def self.count
      all.count
    end

    def self.destroy_all
      @@all = []
    end

    def initialize(resource_type, options = {})
      @resource_type = resource_type.to_s
      @hierarchy_root = PermissionHierarchyNode.new(resource_type, options)
    end

    def owns(resource_type, options = {}, &block)
      hierarchy_root.owns(resource_type, options, &block)
    end

    def permissions
      hierarchy_root.permissions
    end

    def find_node(permission)
      hierarchy_root.find_child(permission)
    end
    
  end
end