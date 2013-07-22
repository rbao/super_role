module SuperRole
  module ResourcePermission
    extend ActiveSupport::Concern

    included do
      belongs_to :role, class_name: SuperRole.role_class
      belongs_to :permission, class_name: SuperRole.permission_class
      belongs_to :reference, polymorphic: true

      validates :role_id, presence: true
      validates :permission_id, presence: true
    end

    module ClassMethods
      def related_to(actions, resource)
        # resource_permission with no resource_id means either it is a permission for all the 
        # resource relative to the reference or it is an action which does not require a 
        # resource_id, ex. :create.
        joins(:permission).where(SuperRole.permission_class.table_name => { action: actions, resource_type: resource.class }, resource_id: [nil, resource.id].uniq)
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
      else
        return false
      end

      # Find through heirachy
      hierarchy = SuperRole::PermissionHierarchy.find(owner_type)
      return hierarchy.ancestor_resource?(resource, reference, permission) if hierarchy
      false
    end

  end
end