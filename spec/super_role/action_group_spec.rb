require 'spec_helper'

class Project; end
class Contact; end

describe SuperRole::ActionGroup do
  
  describe '.create' do
    
    context 'when tne group does not exist' do
      it 'should create a new instance of action group for each resource_types' do
        expect do
          SuperRole::ActionGroup.create('manage', ['update', 'destroy'], ['Project', 'Contact'])
        end.to change { SuperRole::ActionGroup.count }.by(2)
        
        SuperRole::ActionGroup.find(:manage, Project).actions.should match_array ['update', 'destroy']
        SuperRole::ActionGroup.find('manage', 'Contact').actions.should match_array ['update', 'destroy']
      end
    end

    context 'when the group already exist' do
      before do
        SuperRole::ActionGroup.create('manage', ['update'], ['Project', 'Contact'])
      end

      it 'should add the actions to the existing group' do
        expect do
          SuperRole::ActionGroup.create('manage', ['update', 'destroy'], ['Project', 'Contact'])
        end.to_not change { SuperRole::ActionGroup.count }

        SuperRole::ActionGroup.find(:manage, Project).actions.should match_array ['update', 'destroy']
        SuperRole::ActionGroup.find('manage', 'Contact').actions.should match_array ['update', 'destroy']
      end
    end

  end

end