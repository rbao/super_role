def create_permissions_for(*resource_types)
  resource_types.each do |resource_type|
    ['create', 'update', 'show', 'destroy'].each do |action|
      Permission.create(action: action, resource_type: resource_type.to_s)
    end
  end
end