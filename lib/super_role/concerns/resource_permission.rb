module SuperRole
  module ResourcePermission
    
    extend ActiveSupport::Concern

    included do
      belongs_to :role, class_name: SuperRole.role_class
      belongs_to :permission, class_name: SuperRole.permission_class
      belongs_to :reference, polymorphic: true

      validates :role_id, presence: true
      validates :permission_id, presence: true
      validate :role_and_permission_valid
      validates :resource_id, uniqueness: { scope: [:permission_id, :role_id] }

      delegate :permission_hierarchy, to: :role, allow_nil: true
    end

    module ClassMethods

      def related_to(actions, resource)
        # resource_permission with no resource_id means either it is a permission for all the 
        # resource relative to the reference or it is an action which does not require a 
        # resource_id, ex. :create.
        joins(:permission).where(SuperRole.permission_class.constantize.table_name => { action: actions, resource_type: resource.class }, resource_id: [nil, resource.id].uniq)
      end

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

    private

    def role_and_permission_valid
      errors.add(:role, 'The role is invalid') unless permission_hierarchy
      errors.add(:permission, 'This permission cannot be added to the role2') if permission_hierarchy && !permission_hierarchy.find_node(permission)
    end

  end
end