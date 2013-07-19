module SuperRole
  class PermissionHierarchy

    cattr_reader :all
    @@all = []

    attr_reader :resource_type, :root

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
      @root = PermissionHierarchyNode.new(resource_type, options)
    end

    # @see SuperRole::PermissionHierarchyNode#owns
    def owns(resource_type, options = {}, &block)
      root.owns(resource_type, options, &block)
    end

    def permissions
      root.permissions
    end

    def find_node(permission)
      root.find_child(permission)
    end

    def resources_match_hierarchy?(resource1, resource2, permission)
      node = find_node(permission)
      node.resource_is_included?(resource1, resource)
    end
    
  end
end