module SuperRole
  module Role
    extend ActiveSupport::Concern

    included do
      has_many :resource_permissions, class_name: SuperRole.resource_permission_class

      validate :owner_type_permitted
    end

    def can?(action, resource_or_resource_type)
      # Do we really nee this check?
      return false unless SuperRole::RoleOwner(owner).owns?(resource)

      resource = resourcify(resource_or_resource_type)
      resource_type = resource_type

      group = ActionGroup.find(action, resource_type)
      action_alias = ActionAlias.find(action, resource_type)
      
      if group
        actions_to_check = group.actions
      elsif action_alias
        actions_to_check = [action_alias.action]
      else
        actions_to_check = [action]
      end

      has_permission?(actions_to_check, resource)
    end

    def resourcify(resource_or_resource_type)
      return resource_or_resource_type.new if resource_or_resource_type.class == Class
      resource_or_resource_type
    end

    def has_permission?(actions, resource)
      actions = Array(actions)
      related_resource_permissions = resource_permissions.related_to(actions, resource)
      
      related_resource_permissions.each do |rp|
        return true if rp.include_resource?(resource)
      end
    end

    def can_have_permission?(permission)
      
    end

    def possible_resources_for_permission(permission, options = {})
      return [] unless can_have_permission?(permission)

      role_owner = SuperRole::RoleOwner.find(owner_type)
      node = role_owner.find_node(permission)
      node.possible_resources_for_owner_instance(owner, options)
    end

    private
      def owner_type_permitted
        role_owner = SuperRole::RoleOwner.find(owner_type)
        errors.add(:base, 'Owner Invalid') unless role_owner
      end

  end
end