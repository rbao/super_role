module SuperRole
  class ActionAlias

    cattr_accessor :all
    @@all = []

    attr_reader :action, :resource_type
    attr_accessor :aliases

    def self.create(aliases, action, resource_types)
      resource_types.each do |rt|
        existing = find(action, rt)
        if existing
          existing.aliases = existing.aliases | aliases
        else
          self.all << ActionAlias.new(aliases, action, rt)
        end
      end
      nil
    end

    # @param [String, Symbol] action
    # @param [Class, String] resource_type
    # @return [SuperRole::ActionAlias, NilClass] The ActionAlias instance if it is found, nil
    #   otherwise.
    def self.find(action, resource_type)
      action = action.to_s
      resource_type = resource_type.to_s

      all.select { |aa| aa.action == action && aa.resource_type == resource_type }.first
    end

    # @return [Integer] The number of action groups created.
    def self.count
      all.count
    end

    # @note This method is only used for testing purposes.
    # Destroy all instance of ActionAlias.
    def self.destroy_all
      self.all = []
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