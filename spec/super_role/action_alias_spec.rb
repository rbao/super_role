require 'spec_helper'

class Project; end
class Contact; end

describe SuperRole::ActionAlias do
  
  describe '.create' do
    
    context 'when the alias does not exist' do
      it 'should create a new instance of ActionAlias for each resource_types' do
        expect do
          SuperRole::ActionAlias.create(['delete', 'remove'], 'destroy', ['Project', 'Contact'])
        end.to change { SuperRole::ActionAlias.count }.by(2)

        SuperRole::ActionAlias.find(:destroy, Project).aliases.should match_array ['delete', 'remove']
        SuperRole::ActionAlias.find('destroy', 'Contact').aliases.should match_array ['delete', 'remove']
      end
    end

    context 'when the group already exist' do
      before do
        SuperRole::ActionAlias.create(['delete'], 'destroy', ['Project', 'Contact'])
      end

      it 'should add the actions to the existing group' do
        expect do
          SuperRole::ActionAlias.create(['remove'], 'destroy', ['Project', 'Contact'])
        end.to_not change { SuperRole::ActionAlias.count }

        SuperRole::ActionAlias.find(:destroy, Project).aliases.should match_array ['delete', 'remove']
        SuperRole::ActionAlias.find('destroy', 'Contact').aliases.should match_array ['delete', 'remove']
      end
    end

  end

end