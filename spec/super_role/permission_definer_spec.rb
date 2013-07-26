require 'spec_helper'

describe SuperRole::PermissionDefiner do
  
  let(:definer) { SuperRole::PermissionDefiner.new }
  let(:default_actions) { definer.default_actions }

  describe '#define_permissions_for' do
    # Can't use a double here because .and_call_original method won't work, but we need
    # that to test if instance_eval is triggered the right number of times.
    let(:definition) { SuperRole::PermissionDefinition.new([]) }

    shared_examples 'for no options and no block' do |resource_types, normalized_resource_types|
      subject { definer.define_permissions_for(resource_types) }

      it 'should add in a definition corresponding to the resource_types with default permissions and aliases' do
        expect(SuperRole::PermissionDefinition).to receive(:new).with(normalized_resource_types).and_return(definition)
        
        expect(definition).to receive(:actions).with(default_actions)
        expect(definition).to receive(:action_alias).with(:new, :create)
        expect(definition).to receive(:action_alias).with(:edit, :update)
        expect(definition).to receive(:instance_eval).and_call_original.once

        expect { subject }.to change { definer.definitions.size }.by 1
      end
    end

    context 'when given a single resource_type' do
      include_examples 'for no options and no block', Project, ['Project']
    end

    context 'when given an array of resource_types' do
      include_examples 'for no options and no block', [Organization, 'Project'], ['Organization', 'Project']
    end

    context 'when given :except option' do
      subject { definer.define_permissions_for(resource_types, options) }
      let(:resource_types) { [Organization, 'Project'] }
      let(:options) { { except: [:create, 'update'] } }

      it 'should only add in the default actions thats not specified in the :except option' do
        expect(SuperRole::PermissionDefinition).to receive(:new).and_return(definition)

        expect(definition).to receive(:actions).with(default_actions - ['create', 'update'])
        expect(definition).to_not receive(:action_alias).with(:new, :create)
        expect(definition).to_not receive(:action_alias).with(:edit, :update)

        expect { subject }.to change { definer.definitions.size }.by 1
      end
    end

    context 'when given :only option' do
      subject { definer.define_permissions_for(resource_types, options) }
      let(:resource_types) { [Organization, 'Project'] }
      let(:options) { { only: [:destroy, 'show'] } }

      it 'should only add in the default actions thats specified in the :only option' do
        expect(SuperRole::PermissionDefinition).to receive(:new).and_return(definition)

        expect(definition).to receive(:actions).with(['destroy', 'show'])
        expect(definition).to_not receive(:action_alias).with(:new, :create)
        expect(definition).to_not receive(:action_alias).with(:edit, :update)

        expect { subject }.to change { definer.definitions.size }.by 1
      end
    end

    context 'when given a block' do
      subject { definer.define_permissions_for(resource_types, &block) }
      let(:resource_types) { [Organization, 'Project'] }
      let(:block) { proc {  } }

      it 'should evaulate the block at the definition instance' do
        expect(SuperRole::PermissionDefinition).to receive(:new).and_return(definition)
        expect(definition).to receive(:instance_eval)
        expect(definition).to receive(:instance_eval).with(&block)

        expect { subject }.to change { definer.definitions.size }.by 1
      end
    end
  end

end