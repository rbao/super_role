module SuperRole
  module Role
    extend ActiveSupport::Concern

    included do
      has_many :resource_permissions, class_name: SuperRole.resource_permission_class

      validate :owner_type_permitted
    end

    def can?(action, resource)
      resource_type = resource.class == Class ? resource : resource.class

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

    def has_permission?(actions, resource)
      return false unless SuperRole::RoleOwner(owner).owns?(resource)
      actions = Array(actions)
      permissions = resource_permissions.get(actions, resource)
      permissions.any?
    end

    def can_have_permission?(permission)
      
    end

    def possible_resources_for_permission(permission, options = {})
      return [] unless can_have_permission?(permission)

      role_owner = SuperRole::RoleOwner.find(owner_type)
      node = role_owner.find_node(permission)
      node.possible_resources_for_owner_instance(owner)
    end

    private
      def owner_type_permitted
        role_owner = SuperRole::RoleOwner.find(owner_type)
        errors.add(:base, 'Owner Invalid') unless role_owner
      end

  end
end