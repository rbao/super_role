module SuperRole
  module Role

    extend ActiveSupport::Concern

    included do
      belongs_to :owner, polymorphic: true
      has_many :resource_permissions, class_name: SuperRole.resource_permission_class

      validate :owner_type_permitted
    end

    def can?(action, resource_or_resource_type)
      resource = resourcify(resource_or_resource_type)
      resource_type = resource_type

      actions_from_group = find_actions_for_group(action, resource_type)
      action_from_alias = find_action_for_alias(action, resource_type)

      if actions_from_group.any?
        actions_to_check = actions_from_group
      elsif action_from_alias
        actions_to_check = [action_from_alias]
      else
        actions_to_check = [action]
      end

      has_permission_to?(actions_to_check, resource)
    end

    def has_permission_to?(actions, resource)
      actions = Array(actions)
      related_resource_permissions = resource_permissions.related_to(actions, resource)

      related_resource_permissions.each do |rp|
        return true if rp.include_resource?(resource)
      end
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

    def owner_type_permitted
      errors.add(:owner, 'Owner Invalid') unless permission_hierarchy
    end

    def resourcify(resource_or_resource_type)
      if resource_or_resource_type.is_a?(String)
        resource_or_resource_type = resource_or_resource_type.constantize
      end

      return resource_or_resource_type.new if resource_or_resource_type.class == Class
      resource_or_resource_type
    end

    def find_actions_for_group(action, resource_type)
      group = ActionGroup.find(action, resource_type)
      return group.actions if group
      []
    end

    def find_action_for_alias(action, resource_type)
      action_alias = ActionAlias.find(action, resource_type)
      return action_alias.action if action_alias
      nil
    end

  end
end