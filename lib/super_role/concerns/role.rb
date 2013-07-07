module SuperRole
  module Role
    extend ActiveSupport::Concern

    included do
      has_many :resource_permissions, class_name: SuperRole.resource_permission_class
    end

    def can?(action, resource)
      resource_type = resource.class == Class ? resource : resource.class

      group = ActionGroup.find(action, resource_type)
      action_alias = ActionAlias.find(action, resource_type)
      
      if group
        actions_to_check = group.actions
      elsif action_alias
        actions_to_check = [action_alias.real_action]
      else
        actions_to_check = [action]
      end

      has_permission?(actions_to_check, resource)
    end

    def has_permission?(actions, resource)
      return false if SuperRole::RoleOwner(owner).has_child?(resource)
      actions = Array(actions)
      permissions = resource_permissions.get(actions, resource)
      permissions.any?
    end

  end
end