module SuperRole
  class PermissionHierarchyNode
    
    include DslNormalizationHelper

    attr_reader :children, :parent, :resource_type, :parent_foreign_key, :actions, :node_permissions

    # @param [String] resource_type
    # @param [Array<String>] actions
    def initialize(resource_type, options = {})
      @parent = options[:parent]
      @children = []
      @resource_type = resource_type
      @actions = actions_according_to_options(options)
      @parent_foreign_key = options[:foreign_key]

      if parent && !@parent_foreign_key
        auto_foreign_key = foreign_key_for(parent.resource_type)
        @parent_foreign_key ||= auto_foreign_key
        @parent_foreign_key ||= parent.resource_type.parameterize.underscore + "_id" if parent
      end

      @node_permissions = []
      actions.each do |action|
        permission = SuperRole.permission_class.find_by(action: action, resource_type: resource_type)
        raise "Permission Not Found" unless permission
        node_permissions << permission
      end
    end

    # @note This is a DSL method used in the role owner definition file.
    def owns(resource_type, options = {}, &block)
      resource_type = resource_type.to_s

      child = PermissionHierarchyNode.new(resource_type, options.merge(parent: self))
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
      return self if node_permissions.include?(permission)
      
      children.each do |child|
        result = child.find_child(permission)
        return result if result
      end

      nil
    end

    def related_resource?(source_resource, target_resource)
      possible_parent_resource_ids = parent.possible_ids_for_ancestor_resource(target_resource)
      parent_resource_id = source_resource.send(parent_foreign_key)
      return if possible_parent_resource_ids.include?(parent_resource_id)
    end

    def possible_resources_for_ancestor_resource(ancestor_resource)
      return resource_type.constantize.where(id: ancestor_resource.id) if ancestor_resource.class.to_s == resource_type
      return resource_type.constantize.none unless parent
      # Return all existing ids if the parent node is nil, ie. resource_type is the empty string
      return resource_type.constantize.all.pluck(:id) if parent.resource_type.blank?

      possible_parent_resource_ids = parent.possible_ids_for_ancestor_resource(ancestor_resource)
      resource_type.constantize.where(parent_foreign_key => possible_parent_resource_ids)
    end

    protected

    def possible_ids_for_ancestor_resource(ancestor_resource)
      return resource_type.constantize.where(id: ancestor_resource.id).pluck(:id) if ancestor_resource.class.to_s == resource_type
      return resource_type.constantize.none unless parent
      # Return all existing ids if the parent node is nil, ie. resource_type is the empty string
      return resource_type.constantize.all.pluck(:id) if parent.resource_type.blank?

      possible_parent_resource_ids = parent.possible_ids_for_ancestor_resource(ancestor_resource)
      resource_type.constantize.where(parent_foreign_key => possible_parent_resource_ids).pluck(:id)
    end

    private

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

    def foreign_key_for(target_resource_type)
      all_reflections = resource_type.constantize.reflect_on_all_associations(:belongs_to)

      all_reflections.each do |reflection|
        return reflection.foreign_key if reflection.klass.to_s == target_resource_type
      end
      nil
    end

  end
end