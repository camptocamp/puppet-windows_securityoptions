require 'spec_helper'

describe Puppet::Type.type(:so_privilegerights) do
  let(:invalid_name) { 'Manage invalide privilege right name' }
  let(:valid_name) { 'Access this computer from the network' }

  context 'when using namevar' do
    it 'has a namevar' do
      expect(described_class.key_attributes).to eq([:name])
    end
  end

  context 'when validating name with secedit_mappingtable' do
    # checking name with secedit_mapping.json
    it 'fails with an invalid name' do
      expect {
        described_class.new(
          name: invalid_name,
        )
      }.to raise_error(Puppet::ResourceError, %r{Invalid display name: \'Manage invalide privilege right name\'})
    end

    it 'passes with a valid name' do
      expect {
        described_class.new(
          name: valid_name,
        )
      }.should be_truthy
    end
  end

  context 'when validating ensure' do
    it 'is ensurable' do
      expect(described_class.attrtype(:ensure)).to eq(:property)
    end

    it 'is ensured to present by default' do
      res = described_class.new(title: valid_name)
      expect(res[:ensure]).to eq(:present)
    end

    it 'is ensurable to absent' do
      res = described_class.new(
        title: valid_name,
        ensure: :absent,
      )
      expect(res[:ensure]).to eq(:absent)
    end
  end
end
