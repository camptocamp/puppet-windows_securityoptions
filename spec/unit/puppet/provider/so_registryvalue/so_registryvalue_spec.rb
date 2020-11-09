require 'spec_helper'
require 'stringio'
require 'puppet/util'
require 'pathname'

require File.expand_path('../../../../../spec/fixtures/modules/inifile/lib/puppet/util/ini_file', __FILE__) if File.file?('../../../../../spec/fixtures/modules/inifile/lib/puppet/util/ini_file')

describe Puppet::Type.type(:so_registryvalue).provider(:so_registryvalue) do
  let(:params) do
    {
      title: 'Audit: Audit the use of Backup and Restore privilege',
      ensure: 'present',
      sovalue: 0,
      provider: :so_registryvalue,
    }
  end

  let(:resource) do
    Puppet::Type.type(:so_registryvalue).new(params)
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
    [:exists?, :create, :destroy, :sovalue, :sovalue=].each do |method|
      it { is_expected.to respond_to(method) }
    end
  end

  context 'when using prefetch' do
    it 'does not exist before prefetch' do
      expect(resource.provider.exists?).to eq(false)
      expect(resource.provider.sovalue).to eq(nil)
    end

    it 'exists after prefetch' do
      stub_secedit_export
      provider.class.prefetch(hashresource)
      expect(resource.provider.exists?).to eq(true)
      expect(resource.provider.sovalue).to eq(42)
    end
  end

  context 'when listing instances' do
    before(:each) do
      stub_secedit_export
      @instances = provider.class.instances.map do |i|
        {
          name: i.get(:name),
          ensure: i.get(:ensure),
          sovalue: i.get(:sovalue),
        }
      end
    end

    it 'lists all instances' do
      expect(@instances.size).to eq(72)
    end

    it 'finds Interactive logon with a quoted string (type 1)' do
      example1 = @instances.find do |p|
        p[:name].casecmp('Interactive logon: Smart card removal behavior'.downcase).zero?
      end
      expect(example1).to eq(name: 'Interactive logon: Smart card removal behavior',
                             ensure: :present,
                             sovalue: '"1"')
    end

    it 'finds Audit with an integer (type 3)' do
      example3 = @instances.find do |p|
        p[:name].casecmp('Audit: Audit the use of Backup and Restore privilege'.downcase).zero?
      end
      expect(example3).to eq(name: 'Audit: Audit the use of Backup and Restore privilege',
                             ensure: :present,
                             sovalue: 42)
    end

    it 'finds Recovery console with an integer (type 4)' do
      example4 = @instances.find do |p|
        p[:name].casecmp('Recovery console: Allow automatic administrative logon'.downcase).zero?
      end
      expect(example4).to eq(name: 'Recovery console: Allow automatic administrative logon',
                             ensure: :present,
                             sovalue: 0)
    end

    it 'finds System settings with an empty array (type 7)' do
      example7a = @instances.find { |p| p[:name].casecmp('System settings: Optional subsystems'.downcase).zero? }
      expect(example7a).to eq(name: 'System settings: Optional subsystems',
                              ensure: :present,
                              sovalue: '')
    end

    it 'finds Interactive logon with an array (type 7)' do
      example7b = @instances.find do |p|
        p[:name].casecmp('Interactive logon: Message text for users attempting to log on'.downcase).zero?
      end
      expect(example7b).to eq(name: 'Interactive logon: Message text for users attempting to log on',
                              ensure: :present,
                              sovalue: 'By logging in I understand that the information on this computer and network system is Company property protected by law and that it may be accessed and used only by authorized personel and that my use may be monitored.')
    end

    it 'finds Network access with an array (type 7)' do
      example7c = @instances.find do |p|
        p[:name].casecmp('Network access: Remotely accessible registry paths and sub-paths'.downcase).zero?
      end
      expect(example7c).to eq(name: 'Network access: Remotely accessible registry paths and sub-paths',
                              ensure: :present,
                              sovalue: 'System\\CurrentControlSet\\Control\\Print\\Printers,System\\CurrentControlSet\\Services\\Eventlog,Software\\Microsoft\\OLAP Server,Software\\Microsoft\\Windows NT\\CurrentVersion\\Print,Software\\Microsoft\\Windows NT\\CurrentVersion\\Windows,System\\CurrentControlSet\\Control\\ContentIndex,System\\CurrentControlSet\\Control\\Terminal Server,System\\CurrentControlSet\\Control\\Terminal Server\\UserConfig,System\\CurrentControlSet\\Control\\Terminal Server\\DefaultUserConfiguration,Software\\Microsoft\\Windows NT\\CurrentVersion\\Perflib,System\\CurrentControlSet\\Services\\SysmonLog')
    end
  end

  def stub_write_export(value)
    allow(File).to receive(:open).and_call_original
    expect(Puppet).to receive(:[]).at_least(:once).with(:vardir).and_return(vardir)
    expect(Dir).to receive(:mkdir).at_least(:once).with(File.join(vardir, 'rvimports'))
    writeFile = StringIO.new
    expect(File).to receive(:open).at_least(:once).with('C:\\ProgramData\\PuppetLabs\\Puppet\\cache\\rvimports\\auditaudittheuseofbackupandrestoreprivilege.txt', 'w').and_yield(writeFile)
    expect(writeFile).to receive(:write).with("[Unicode]
Unicode=yes
[Registry Values]
MACHINE\\System\\CurrentControlSet\\Control\\Lsa\\FullPrivilegeAuditing = 3,#{value}
[Version]
signature=\"$CHICAGO$\"
Revision=1
")
  end

  def stub_flush(path)
    expect(provider.class).to receive(:secedit).at_least(:once).with('/configure', '/db', tmp_sdb_file, '/cfg', path)
  end

  context 'when updating value' do
    it 'updates value' do
      stub_write_export(3)
      expect(provider.sovalue).to eq(nil)
      provider.sovalue = 3
      expect(provider.sovalue).to eq(3)
      stub_flush('C:\\ProgramData\\PuppetLabs\\Puppet\\cache\\rvimports\\auditaudittheuseofbackupandrestoreprivilege.txt')
      provider.flush
    end
  end
end
