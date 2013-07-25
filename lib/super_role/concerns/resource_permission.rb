module SuperRole
  module ResourcePermission
    extend ActiveSupport::Concern

    included do
      belongs_to :role, class_name: SuperRole.role_class
      belongs_to :permission, class_name: SuperRole.permission_class
      belongs_to :reference, polymorphic: true

      validates :role_id, presence: true
      validates :permission_id, presence: true
      validates :resource_id, uniqueness: { scope: [:permission_id, :role_id] }
      validate :permission_valid_for_role
    end

    module ClassMethods
      def related_to(actions, resource)
        # resource_permission with no resource_id means either it is a permission for all the 
        # resource relative to the reference or it is an action which does not require a 
        # resource_id, ex. :create.
        joins(:permission).where(SuperRole.permission_class.constantize.table_name => { action: actions, resource_type: resource.class }, resource_id: [nil, resource.id].uniq)
      end

      def with_resource_type(actions, resource_type)
        joins(:permission).where(permissions: { action: actions, resource_type: resource_type }, resource_id: nil)
      end
    end

    def owner
      role.owner
    end

    def owner_type
      role.owner_type
    end

    # @param [#persisted?#id] name_and_desc
    def include_resource?(resource)
      
      if resource.persisted?
        return true if resource.id == resource_id
      end

      # Find through heirachy
      return permission_hierarchy.ancestor_resource?(resource, reference, permission) if permission_hierarchy
      false
    end

    def permission_hierarchy
      if @permission_hierarchy && @permission_hierarchy.resource_type == owner_type
        return @permission_hierarchy 
      end

      @permission_hierarchy = SuperRole::PermissionHierarchy.find(owner_type)
      @permission_hierarchy
    end

    private

    def permission_valid_for_role
      errors.add(:permission, 'This permission cannot be added to the role1') unless permission_hierarchy
      errors.add(:permission, 'This permission cannot be added to the role2') unless permission_hierarchy.find_node(permission)
    end

  end
end