require 'spec_helper'

describe Puppet::Type.type(:user_right) do
    let(:valid_right) { 'seassignprimarytokenprivilege' }

    context 'when using namevar' do
        it 'should have a namevar' do
            expect(described_class.key_attributes).to eq([:name])
        end
    end

    context 'when validating name' do
        it 'should accept a valid string' do
            res = described_class.new(:title => valid_right)
            expect(res[:name]).to eq(valid_right)
        end

        it 'should fail with an invalid right' do
            expect {
                described_class.new(
                    :title => 'abc1',
                )
            }.to raise_error(Puppet::Error, /Not a valid name: 'abc1'/)
        end
    end

    context 'when validating ensure' do
        it 'should be ensurable' do
            expect(described_class.attrtype(:ensure)).to eq(:property)
        end

        it 'should be ensured to present by default' do
            res = described_class.new(:title => valid_right)
            expect(res[:ensure]).to eq(:present)
        end

        it 'should be ensurable to absent' do
            res = described_class.new(
                :title  => valid_right,
                :ensure => :absent
            )
            expect(res[:ensure]).to eq(:absent)
        end
    end
end
