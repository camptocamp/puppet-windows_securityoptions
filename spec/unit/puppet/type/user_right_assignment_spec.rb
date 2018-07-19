require 'spec_helper'

describe Puppet::Type.type(:user_right_assignment) do
    let(:valid_right) { 'seassignprimarytokenprivilege' }

    context 'when validating right' do
        it 'should accept a valid string' do
            res = described_class.new(:title => 'abc', :right => valid_right)
            expect(res[:right]).to eq(valid_right)
        end

        it 'should fail with an invalid right' do
            expect {
                described_class.new(
                    :title => 'abc',
                    :right => 'abc1',
                )
            }.to raise_error(Puppet::Error, /Not a valid right name: 'abc1'/)
        end
    end
end
