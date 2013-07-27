module SuperRole
  class PermissionHierarchyNode
    
    include InputNormalizationHelper

    attr_reader :children, :parent, :resource_type, :actions, :parent_foreign_key, :polymorphic, :node_permissions

    # @param [String] resource_type
    # @param [Array<String>] actions
    def initialize(resource_type, options = {})
      raise ForeignKeyRequiredForPolymorphicNode if options[:polymorphic] && !options[:foreign_key]
      
      @children = []
      @parent = options[:parent]
      @resource_type = resource_type
      @actions = extract_actions_from_options(options)
      @polymorphic = !!options[:polymorphic]
      @parent_foreign_key = extract_foreign_key_from_options(options)

      @node_permissions = []
      actions.each do |action|
        permission = permission_class.find_by(action: action, resource_type: resource_type)
        raise PermissionNotFound, "The permission with action '#{action}' and resource_type '#{resource_type}' was not found" unless permission

        node_permissions << permission
      end
    end

    def default_actions
      permission_class.where(resource_type: resource_type).pluck(:action)
    end

    # @note This is a DSL method used in the role owner definition file.
    def owns(resource_type, options = {}, &block)
      resource_type = resource_type.to_s

      child = PermissionHierarchyNode.new(resource_type, options.merge(parent: self))
      child.instance_eval(&block) if block_given?
      children << child
      nil
    end

    def permissions
      node_permissions + children_permissions
    end

    def children_permissions
      children.flat_map(&:permissions)
    end

    def find_descendant(permission)
      return self if node_permissions.include?(permission)
      
      children.each do |child|
        result = child.find_descendant(permission)
        return result if result
      end

      nil
    end

    # @param [ActiveRecord::Relation] name_and_desc
    def possible_resources_for_ancestor_resource(ancestor_resource)
      raise "Cannot find possible resources for the nil node" if resource_type.blank?
      return resource_type.constantize.where(id: ancestor_resource.id) if ancestor_resource.class.to_s == resource_type
      return resource_type.constantize.none unless parent
      # Return all existing ids if the parent node is nil, ie. resource_type is the empty string
      return resource_type.constantize.all if parent.resource_type.blank? && ancestor_resource.nil?
      return resource_type.constantize.none unless parent_foreign_key

      possible_parent_resource_ids = parent.possible_ids_for_ancestor_resource(ancestor_resource)
      resource_type.constantize.where(parent_foreign_key => possible_parent_resource_ids)
    end

    def ancestor_resource?(resource, target_resource)
      return true if parent.resource_type.blank? && target_resource.nil?

      possible_parent_resource_ids = parent.possible_ids_for_ancestor_resource(target_resource)
      parent_resource_id = resource.send(parent_foreign_key)
      return true if possible_parent_resource_ids.include?(parent_resource_id)
      
      false
    end

    protected

    def possible_ids_for_ancestor_resource(ancestor_resource)
      return resource_type.constantize.where(id: ancestor_resource.id).pluck(:id) if ancestor_resource.class.to_s == resource_type
      return [] unless parent
      # If the given ancestore_resource is nil and nil_node exist in the hierarchy then return everything
      return resource_type.constantize.all.pluck(:id) if parent.resource_type.blank? && ancestor_resource.nil?
      return [] unless parent_foreign_key

      possible_parent_resource_ids = parent.possible_ids_for_ancestor_resource(ancestor_resource)

      if polymorphic
        type_column = parent_foreign_key.chomp('id') + 'type'
        return resource_type.constantize.where(
          parent_foreign_key => possible_parent_resource_ids, 
          type_column => parent.resource_type).pluck(:id)
      end

      resource_type.constantize.where(parent_foreign_key => possible_parent_resource_ids).pluck(:id)
    end

    private

    def permission_class
      SuperRole.permission_class.constantize
    end

    def extract_actions_from_options(options)
      only = arrayify_then_stringify_items(options[:only])
      except = arrayify_then_stringify_items(options[:except])

      actions = only.any? ? only : default_actions
      actions -= except
      actions
    end

    def extract_foreign_key_from_options(options)
      return if parent && parent.resource_type.blank?
      return options[:foreign_key].to_s if options[:foreign_key]

      if parent && !options[:foreign_key]
        auto_foreign_key = foreign_key_for(parent.resource_type)
        return auto_foreign_key if auto_foreign_key
        return parent.resource_type.underscore.parameterize + "_id" if parent
      end
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