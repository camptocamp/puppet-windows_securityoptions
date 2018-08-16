require 'spec_helper'

describe Puppet::Type.type(:so_registryvalue) do
    let(:valid_name) { 'Shutdown: Clear virtual memory pagefile' }
    let(:invalid_name) { 'Shutdown: Why do you want to shutdown' }
    #I pulled this from the spec filr for acl module .. spec/unit/puppet/type/acl_spec.rb
    let(:resource) { Puppet::Type.type(:so_registryvalue).new(:name => valid_name, :title => valid_name) }
    let(:provider) { Puppet::Provider.new(resource) }
    let(:catalog)  { Puppet::Resource::Catalog.new }

    context 'when validating ensure' do
        it 'should be ensurable' do
            expect(described_class.attrtype(:ensure)).to eq(:property)
        end

        it 'should be ensured to present by default' do
            res = described_class.new(:title => valid_name)
            expect(res[:ensure]).to eq(:present)
        end

        it 'should be ensurable to absent' do
            res = described_class.new(
                :title  => valid_name,
                :ensure => :absent
            )
            expect(res[:ensure]).to eq(:absent)
        end
    end

  context 'name parameter' do
  #I pulled this from ura, but it does not fail when namevar is not set
  #so I am not sure what this is checking
    it 'should have a namevar' do
      expect(described_class.key_attributes).to eq([:name])
    end
    it "should be the name var" do
      resource.parameters[:name].isnamevar?.should be_truthy
    end

    it 'should fail with an invalid name' do
        expect {
            described_class.new(
                :name => invalid_name,
            )
        }.to raise_error(Puppet::ResourceError, /Invalid Policy name: \'Shutdown: Why do you want to shutdown\'/)
    end
    it 'should pass with a valid name' do
        expect {
            described_class.new(
                :name => valid_name,
            )
        }.should be_truthy
    end


  end



end
