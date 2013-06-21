module SuperRole
  module Role
    extend ActiveSupport::Concern

    included do
      has_many :resource_permissions, class_name: SuperRole.resource_permission_class
    end

    def can?(action, resource)
      resource_type = resource.class == Class ? resource : resource.class

      group = PermissionGroup.find(action, resource_type)
      action_alias = PermissionAlias.find(action, resource_type)
      
      if group
        actions_to_check = group.permissions
      elsif actions_alias
        actions_to_check = [actions_alias.real_action]
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