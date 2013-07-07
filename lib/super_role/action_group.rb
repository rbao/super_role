module SuperRole
  class ActionGroup
    cattr_accessor :all
    @@all = []

    attr_reader :name, :resource_type
    attr_accessor :actions

    # @param [Array<String>] actions The actions that belongs to the group.
    # @param [Array<String>] resource_types The resource_types to to create
    #   the action group for.
    def self.create(name, actions, resource_types)
      resource_types.each do |rt|
        existing = find(actions, rt)
        if existing
          existing.actions = existing.actions | actions
        else
          self.all << ActionGroup.new(name, actions, rt)
        end
      end
      true
    end

    def self.find(name, resource_type)
      name = name.to_s
      resource_type = resource_type.to_s

      self.all.select { |ag| ag.name == name && ag.resource_type == resource_type }.first
    end

    def self.count
      self.all.count
    end

    def self.destroy_all
      self.all = []
    end

    def initialize(name, actions, resource_type)
      @name = name
      @actions = actions
      @resource_type = resource_type
    end
  end
end