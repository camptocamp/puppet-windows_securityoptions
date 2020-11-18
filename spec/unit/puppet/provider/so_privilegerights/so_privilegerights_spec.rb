require 'spec_helper'
require 'stringio'
require 'puppet/util'
require 'pathname'

require File.expand_path('../../../../../spec/fixtures/modules/inifile/lib/puppet/util/ini_file', __FILE__) if File.file?('../../../../../spec/fixtures/modules/inifile/lib/puppet/util/ini_file')

describe Puppet::Type.type(:so_privilegerights).provider(:so_privilegerights) do
  let(:params) do
    {
      title: 'sechangenotifyprivilege',
      ensure: 'present',
      sid: ['DOMAIN\user1', 'DOMAIN\group1'],
      provider: :so_privilegerights,
    }
  end

  let(:resource) do
    Puppet::Type.type(:so_privilegerights).new(params)
  end

  let (:hashresource) do
    {
      params[:title] => resource,
    }
  end

  let(:provider) do
    resource.provider
  end

  let(:vardir) do
    'C:\ProgramData\PuppetLabs\Puppet\cache'
  end

  let(:tmp_sdb_file) do
    File.join(vardir, '/secedit.sdb').tr('/', '\\')
  end

  def stub_secedit_export
    ini_stub = Puppet::Util::IniFile.new(File.join(File.dirname(__FILE__), '../../../../../lib/puppet_x/securityoptions/securityoptionsoutput.txt'), '=')
    expect(provider.class).to receive(:secedit_exports).at_least(:once)
                                                       .and_return(ini_stub)
  end

  context 'when checking standard methods' do
    [:exists?, :create, :destroy, :sid, :sid=].each do |method|
      it { is_expected.to respond_to(method) }
    end
  end

  context 'when using prefetch' do
    it 'does not exist before prefetch' do
      expect(resource.provider.exists?).to eq(false)
      expect(resource.provider.sid).to eq(nil)
    end

    it 'exists after prefetch' do
      stub_secedit_export
      provider.class.prefetch(hashresource)
      expect(resource.provider.exists?).to eq(true)
      expect(resource.provider.sid).to eq(['*S-1-5-19', '*S-1-5-20', '*S-1-5-32-544', '*S-1-5-32-545', '*S-1-5-32-551'])
    end
  end

  context 'when listing instances' do
    before(:each) do
      stub_secedit_export
      @instances = provider.class.instances.map do |i|
        {
          name: i.get(:name),
          ensure: i.get(:ensure),
          sid: i.get(:sid),
        }
      end
    end

    it 'lists all instances' do
      expect(@instances.size).to eq(32)
    end
  end

  def stub_write_export(value)
    allow(File).to receive(:open).and_call_original
    expect(Puppet).to receive(:[]).at_least(:once).with(:vardir).and_return(vardir)
    expect(Dir).to receive(:mkdir).at_least(:once).with(File.join(vardir, 'primports'))
    writeFile = StringIO.new
    expect(File).to receive(:open).at_least(:once).with('C:\\ProgramData\\PuppetLabs\\Puppet\\cache\\primports\\sechangenotifyprivilege.txt', 'w').and_yield(writeFile)
    expect(writeFile).to receive(:write).with("[Unicode]
Unicode=yes
[Privilege Rights]
sechangenotifyprivilege = *S-1-5-19
[Version]
signature=\"$CHICAGO$\"
Revision=1
")
  end

  def stub_flush(path)
    expect(provider.class).to receive(:secedit).at_least(:once).with('/configure', '/db', tmp_sdb_file, '/cfg', path)
  end

  context 'when updating value' do
    Puppet::Util::Windows::SID.stubs(:name_to_sid).returns('S-1-5-19')

    it 'updates value' do
      stub_write_export(3)
      expect(provider.sid).to eq(nil)
      provider.sid = ['DOMAIN\user2']
      expect(provider.sid).to eq(['DOMAIN\user2'])
      stub_flush('C:\\ProgramData\\PuppetLabs\\Puppet\\cache\\primports\\sechangenotifyprivilege.txt')
      provider.flush
    end
  end
end
