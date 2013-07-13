module SuperRole
  class ActionAlias

    cattr_reader :all
    @@all = []

    attr_reader :action, :resource_type
    attr_accessor :aliases

    def self.create(aliases, action, resource_types)
      resource_types.each do |rt|
        existing = find_by_action(action, rt)
        if existing
          existing.aliases = existing.aliases | aliases
        else
          @@all << ActionAlias.new(aliases, action, rt)
        end
      end
      nil
    end

    def self.find_by_action(action, resource_type)
      action = action.to_s
      resource_type = resource_type.to_s

      all.select { |aa| aa.action == action && aa.resource_type == resource_type }.first
    end

    # @param [String, Symbol] action_alias
    # @param [Class, String] resource_type
    # @return [SuperRole::ActionAlias, NilClass] The ActionAlias instance if it is found, nil
    #   otherwise.
    def self.find(action_alias, resource_type)
      action_alias = action_alias.to_s
      resource_type = resource_type.to_s

      all.select { |aa| aa.aliases.include?(action_alias) }.first
    end

    # @return [Integer] The number of action groups created.
    def self.count
      all.count
    end

    # @note This method is only used for testing purposes.
    # Destroy all instance of ActionAlias.
    def self.destroy_all
      @@all = []
    end

    ## Instance Methods ##

    # @param [Array<String>] aliases
    # @param [String] action
    # @param [String] resource_type
    def initialize(aliases, action, resource_type)
      @aliases = aliases
      @action = action
      @resource_type = resource_type
    end

  end
end