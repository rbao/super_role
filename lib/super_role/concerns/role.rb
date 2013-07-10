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
      return false if SuperRole::RoleOwner(owner).has_child?(resource)
      actions = Array(actions)
      permissions = resource_permissions.get(actions, resource)
      permissions.any?
    end

    def can_have_permission?(action, resource_type)
      
    end

    def possible_resources_for_permission(action, resource_type, options = {})
      return [] unless can_have_permission?(action, resource_type)

      # TODO: need to figure out a way to implement this for something like
      # Organization project.org_id ticket.proj_id
      # where we are looking for possible resource of ticket, but our owner is
      # Organization.
      node = SuperRole::PermissionHierarchyNode.find(resource_type)
      foreign_key = node.foreign_key_for(owner)
      resource_type.where(foreign_key => owner_id)
      
      
    end

    private
      def owner_type_permitted
        role_owner = SuperRole::RoleOwner.find_by_owner_type(owner_type)
        errors.add(:base, 'Owner Invalid') unless role_owner
      end

  end
end