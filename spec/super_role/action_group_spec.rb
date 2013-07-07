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
      end
    end  
  end

end