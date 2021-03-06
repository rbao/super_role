module SuperRole
  module Role

    extend ActiveSupport::Concern

    included do
      belongs_to :owner, polymorphic: true
      has_many :resource_permissions, class_name: SuperRole.resource_permission_class

      validate :owner_type_permitted
    end

    def can?(actions, resource_or_resource_type, options = {})
      resource = resourcify(resource_or_resource_type)
      resource_type = resource.class
      any = !!options[:any]

      actions = extract_actual_actions(actions, resource_type)

      actions.each do |action|
        if any
          return true if has_permission_to?(action, resource)
        else
          return false unless has_permission_to?(action, resource)
        end
      end

      return true unless any
      false
    end

    def has_permission_to?(action, resource)
      related_resource_permissions = resource_permissions.related_to(action, resource)

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

    def extract_actual_actions(actions, resource_type)
      actions = Array(actions)
      actual_actions = []
      
      actions.each do |action|
        actions_from_group = find_actions_for_group(action, resource_type)
        action_from_alias = find_action_for_alias(action, resource_type)

        if actions_from_group.any?
          actual_actions += actions_from_group
        elsif action_from_alias
          actual_actions << action_from_alias
        else
          actual_actions << action
        end
      end

      actual_actions
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