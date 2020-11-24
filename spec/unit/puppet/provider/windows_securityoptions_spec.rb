require 'spec_helper'


Puppet::Type.newtype(:faketype) do
  newparam(:name, namevar: true)
  newparam(:sid)
end

class FakeProvider < Puppet::Provider::Windows_SecurityOptions
  # Instances "found" on the node by the provider
  def self.instances
    [
      new({
        name: 'foo',
        sid: 'FOO',
      }),
      new({
        name: 'baz',
        sid: 'BAZ',
      }),
    ]
  end
end


describe Puppet::Provider::Windows_SecurityOptions do
  let(:subject) { FakeProvider.new }

  # Fake resource type to test the provider
  let(:restype) { Puppet::Type::Faketype }

  # Hash of catalog resources
  let(:resources) do
    {
      foo: restype.new({
        name: 'foo',
      }),

      bar: restype.new({
        name: 'bar',
      }),
    }
  end

  # Catalog resource
  let(:resource) do
    restype.new({
      name: 'foo',
      sid: 'FOO',
    })
  end

  describe :create do
    it 'calls write_export' do
      # associate `resource` with a FakeProvider instance
      resource.provider = subject.class.instances[0]
      # FakeProvider will call write_export when creating the resource
      expect(resource.provider).to receive(:write_export).with('foo', 'FOO')
      resource.provider.create
    end
  end

  describe :destroy do
    it 'calls write_export' do
      resource.provider = subject.class.instances[0]
      expect(resource.provider).to receive(:write_export).with('foo', [])
      resource.provider.destroy
    end
  end

  describe :prefetch do
    it 'maps instances to provider' do
      subject.class.prefetch(resources)

      expect(resources[:foo].provider).to eq(subject.class.instances[0])
      expect(resources[:bar].provider).to eq(nil)

      #expect(resources[:foo].provider.exists?).to eq(true)
    end
  end
end
