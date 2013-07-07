require 'spec_helper'

describe SuperRole::PermissionDefiner do
  let(:definer) { SuperRole::PermissionDefiner.new }

  describe '#extract_actions_from_options' do

    subject { definer.extract_actions_from_options(options) }
    
    before do
      definer.stub(:default_actions => ['create', 'show', 'update', 'destroy'])
    end

    context 'when given options are empty' do
      let(:options) { {} }
      it('should return the default actions') { should eq definer.default_actions }
    end

    context 'when the :only key is a single action symbol' do
      let(:options) { { only: :single_action } }
      it { should eq ['single_action'] }
    end

    context 'when the :only key is an array of action symbols' do
      let(:options) { { only: [:action1, :action2] } }
      it { should eq ['action1', 'action2'] }
    end

    context 'when the :except key is a single action symbol' do
      let(:options) { { except: :update } }
      it { should eq definer.default_actions - ['update'] }
    end

    context 'when the :except key is an array of action symbols' do
      let(:options) { { except: [:create, :update] } }
      it { should eq definer.default_actions - ['create', 'update'] }
    end

    context 'when the :extra key is a single action symbol' do
      let(:options) { { extra: :single_action } }
      it { should eq definer.default_actions + ['single_action'] }
    end

    context 'when the :extra key is an array of action symbols' do
      let(:options) { { extra: [:action1, :action2] } }
      it { should eq definer.default_actions + ['action1', 'action2'] }
    end

  end
end