require 'spec_helper'

describe Puppet::Type.type(:so_systemaccess) do
    let(:valid_sa) { 'Enforce password history' }

    context 'when using namevar' do
        it 'should have a namevar' do
            expect(described_class.key_attributes).to eq([:name])
        end
    end

    context 'when validating name' do
        it 'should accept a valid string' do
            res = described_class.new(:title => valid_sa)
            expect(res[:name].downcase).to eq(valid_sa.downcase)
        end

        it 'should fail with an invalid right' do
            expect {
                described_class.new(
                    :title => 'abc1',
                )
            }.to raise_error(Puppet::Error, /Invalid Policy name: 'abc1'/)
        end
    end

    context 'when validating so_value' do
        it 'should accept a valid string' do
            res = described_class.new(
              :title => valid_sa,
              :sovalue => 'string')
            expect(res[:sovalue]).to eq('string')
        end

        it 'should fail with an invalid right' do
            expect {
                described_class.new(
                    :title => valid_sa,
                    :sovalue => 1,
                )
            }.to raise_error(Puppet::Error, /sovalue must be a string idiot!/)
        end

        it 'should fail with an invalid right' do
            expect {
                described_class.new(
                    :title => valid_sa,
                    :sovalue => [1,2,3],
                )
            }.to raise_error(Puppet::Error, /sovalue must be a string idiot!/)
        end
    end

    context 'when validating ensure' do
        it 'should be ensurable' do
            expect(described_class.attrtype(:ensure)).to eq(:property)
        end

        it 'should be ensured to present by default' do
            res = described_class.new(:title => valid_sa)
            expect(res[:ensure]).to eq(:present)
        end

        it 'should be ensurable to absent' do
            res = described_class.new(
                :title  => valid_sa,
                :ensure => :absent
            )
            expect(res[:ensure]).to eq(:absent)
        end
    end
end
