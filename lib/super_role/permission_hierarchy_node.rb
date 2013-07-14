module SuperRole
  class PermissionHierarchyNode
    
    include DslNormalizationHelper

    attr_reader :children, :parent, :resource_type, :parent_foreign_key, :actions, :node_permissions

    # @param [String] resource_type
    # @param [Array<String>] actions
    def initialize(resource_type, options = {})
      @children = []
      @resource_type = resource_type
      @actions = actions_according_to_options(options)
      
      @node_permissions = []
      actions.each do |action|
        permission = SuperRole.permission_class.find_by(action: action, resource_type: resource_type)
        raise "Permission Not Found" unless permission
        node_permissions << permission
      end
    end

    def default_actions
      SuperRole.permission_class.where(resource_type: resource_type).pluck(:action)
    end

    def actions_according_to_options(options)
      only = arrayify_then_stringify_items(options[:only])
      except = arrayify_then_stringify_items(options[:except])

      actions = only.any? ? only : default_actions
      actions -= except
      actions
    end

    def owns(resource_type, options = {}, &block)
      resource_type = resource_type.to_s

      child = PermissionHierarchyNode.new(resource_type, options)
      child.instance_eval(&block) if block_given?
      children << child
    end

    def permissions
      node_permissions + children_permissions
    end

    def children_permissions
      children.flat_map(&:permissions)
    end

    def find_child(permission)
      return self if permissions.include?(permission)
      
      children.each do |child|
        result = child.find_child(permission)
        return result if result
      end

      nil
    end

    def possible_resources_for_owner_instance(owner)
      owner unless parent
      possible_parent_resource_ids = parent.possible_resource_ids_for_owner(owner)
      resource_type.constantize.where(parent_foreign_key => possible_parent_resource_ids)
    end

    def possible_resource_ids_for_owner_instance(owner)
      owner.id unless parent
      possible_parent_resource_ids = parent.possible_resource_ids_for_owner(owner_id)
      resource_type.constantize.where(parent_foreign_key => possible_parent_resource_ids).pluck(:id)
    end

  end
end