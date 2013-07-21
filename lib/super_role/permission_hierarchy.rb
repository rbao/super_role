module SuperRole
  class PermissionHierarchy

    cattr_reader :all
    @@all = []

    attr_reader :resource_type, :root

    def self.create(resource_type, options = {})
      new_instance = new(resource_type, options)
      all << new_instance
      new_instance
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
      @root = PermissionHierarchyNode.new(@resource_type, options)
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

    # @return [Boolean] True if the two resources are related according to permission.
    #   Two resources are considered belongs_to each other if resource1 belongs to resource2 or
    #   resource1 belongs_to something that eventually belongs_to resource2.
    def ancestor?(resource1, resource2, permission)
      node = find_node(permission)
      node.ancestor_resource?(resource1, resource2)
    end
    
  end
end