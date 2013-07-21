require 'spec_helper'

describe 'integration' do
  before do
    SuperRole.define_permissions do
      define_permisions_for []
    end
  end
end