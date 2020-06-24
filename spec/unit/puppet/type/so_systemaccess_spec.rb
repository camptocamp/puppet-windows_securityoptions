require 'spec_helper'

describe Puppet::Type.type(:so_systemaccess) do
    let(:valid_name) { 'Accounts: Rename guest account' }
    let(:invalid_name) { 'Shutdown: Why do you want to shutdown' }
    #I pulled this from the spec filr for acl module .. spec/unit/puppet/type/acl_spec.rb
    let(:resource) { Puppet::Type.type(:so_systemaccess).new(:name => valid_name, :title => valid_name) }
    let(:provider) { Puppet::Provider.new(resource) }
    let(:catalog)  { Puppet::Resource::Catalog.new }

    let(:int_resource_name) {'Network access: Allow anonymous SID/Name translation'}
    let(:str_resource_name) {'Accounts: Rename guest account'}

    let(:resourceint) { Puppet::Type.type(:so_systemaccess).new(:name => int_resource_name) }
    let(:resourcestr) { Puppet::Type.type(:so_systemaccess).new(:name => str_resource_name) }

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

  context 'when setting name parameter' do
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
        }.to raise_error(Puppet::ResourceError, /Invalid display name: \'Shutdown: Why do you want to shutdown\'/)
    end
    it 'should pass with a valid name' do
        expect {
            described_class.new(
                :name => valid_name,
            )
        }.should be_truthy
    end


  end

  context 'when setting so_value property' do
    it 'if type qstring should return quoted string, even if it is not quoted' do
        resourcestr[:sovalue] = 'quotedstring'
        expect(resourcestr[:sovalue]).to eq('"quotedstring"')
    end
    it 'if type qstring should return quoted string, even if it is passed an integer' do
        resourcestr[:sovalue] = 4
        expect(resourcestr[:sovalue]).to eq('"4"')
    end
    it 'if type qstring should return quoted string if it is already quoated' do
        resourcestr[:sovalue] = '"quotedstring"'
        expect(resourcestr[:sovalue]).to eq('"quotedstring"')
    end
    it 'if type integer should return integer when passed integer' do
        resourceint[:sovalue] = 0
        expect(resourceint[:sovalue]).to eq(0)
    end
    it 'if type integer should return integer when passed string that can be converted to integer' do
        resourceint[:sovalue] ="0"
        expect(resourceint[:sovalue]).to eq(0)
    end
    it 'if type integer should fail when passed a string that cannot be converted to an integer' do
      expect {
        resourceint[:sovalue] = "0whatisit1"
      }.to raise_error(Puppet::ResourceError, /Invalid value: \'0whatisit1\'.  This must be a number/)
    end
   # it 'if type integer should fail when passed a quoted string which cannot be converted to an integer' do
   #   expect {
   #     resourceint[:sovalue] = '"0"'
   #   }.to raise_error(Puppet::ResourceError, /Invalid value: \'"0"\'. This must be a number/)
   # end

  end

end
