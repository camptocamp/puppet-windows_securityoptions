require 'spec_helper'

describe Puppet::Type.type(:user_rights_assignment) do
    let(:valid_right_name) {'Access this computer from the network'}
    let(:invalid_right_name) {'Manage invalid privilege right name'}

    context 'when validating right' do
        it 'should accept a valid string' do
            res = described_class.new(:title => 'abc', :right => valid_right_name)
            expect(res[:right]).to eq(valid_right_name)
        end

        it 'should fail with an invalid right' do
            expect {
                described_class.new(
                    :title => 'abc',
                    :right => invalid_right_name,
                )
            }.to raise_error(Puppet::Error, /Invalid right name: '#{invalid_right_name}'/)
        end
    end
end
