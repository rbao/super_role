module SuperRole
  class ActionGroup

    cattr_reader :all
    @@all = []

    attr_reader :name, :resource_type
    attr_accessor :actions

    ## Class Methods ##

    # @param [String] name The name of this permission group.
    # @param [Array<String>] actions The actions that belongs to the group.
    # @param [Array<String>] resource_types The resource_types to to create
    #   the action group for.
    def self.create(name, actions, resource_types)
      resource_types.each do |rt|
        existing = find(name, rt)
        if existing
          existing.actions = existing.actions | actions
        else
          @@all << ActionGroup.new(name, actions, rt)
        end
      end
      nil
    end

    # @param [String, Symbol] name
    # @param [Class, String] resource_type
    # @return [SuperRole::ActionGroup, NilClass] The ActionGroup object if it is found, nil
    #   otherwise.
    def self.find(name, resource_type)
      name = name.to_s
      resource_type = resource_type.to_s

      all.select { |ag| ag.name == name && ag.resource_type == resource_type }.first
    end

    # @return [Integer] The number of action groups created.
    def self.count
      all.count
    end

    # @note This method is only used for testing purposes.
    # Destroy all instnace of ActionGroup.
    def self.destroy_all
      @@all = []
    end

    ## Instance Methods ##

    # @param [String] name
    # @param [Array<String>] actions
    # @param [String] resource_type
    def initialize(name, actions, resource_type)
      @name = name
      @actions = actions
      @resource_type = resource_type
    end
  end
end