require 'spec_helper'

describe Puppet::Type.type(:so_privilegerights_fragment) do
  let(:valid_right) { 'seassignprimarytokenprivilege' }
  let(:invalid_name) { 'Manage invalide privilege right name' }

  context 'when validating right' do
    it 'should accept a valid string' do
      res = described_class.new(:title => 'abc', :right => valid_right)
      expect(res[:right]).to eq(valid_right)
    end
    it 'fails with an invalid name' do
      expect {
        described_class.new(
          name: invalid_name,
          right: invalid_name,
        )
      }.to raise_error(Puppet::ResourceError, %r{Invalid name: \'Manage invalide privilege right name\'})
    end
  end
end
