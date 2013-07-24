require 'spec_helper'

describe SuperRole::ActionAlias do
  
  describe '.create' do
    context 'when the alias does not exist' do
      it 'should create a new instance of ActionAlias for each resource_types' do
        expect do
          SuperRole::ActionAlias.create(['delete', 'remove'], 'destroy', ['Project', 'User'])
        end.to change { SuperRole::ActionAlias.count }.by(2)

        SuperRole::ActionAlias.find(:delete, Project).action.should eq 'destroy'
        SuperRole::ActionAlias.find('remove', 'User').action.should eq 'destroy'
      end
    end

    context 'when the an alias already exist' do
      before do
        SuperRole::ActionAlias.create(['delete'], 'destroy', ['Project', 'User'])
      end

      it 'should add the alias to the existing aliases' do
        expect do
          SuperRole::ActionAlias.create(['remove'], 'destroy', ['Project', 'User'])
        end.to_not change { SuperRole::ActionAlias.count }

        SuperRole::ActionAlias.find(:delete, Project).action.should eq 'destroy'
        SuperRole::ActionAlias.find('remove', 'User').action.should eq 'destroy'
      end
    end
  end

end