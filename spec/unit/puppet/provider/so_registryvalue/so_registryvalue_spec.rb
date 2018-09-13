require 'spec_helper'
require 'stringio'

describe Puppet::Type.type(:so_registryvalue).provider(:so_registryvalue) do
   #     {"DisplayName"=>"Audit: Audit the use of Backup and Restore privilege",
   #      "name"=>"MACHINE\\System\\CurrentControlSet\\Control\\Lsa\\FullPrivilegeAuditing",
   #      "reg_type"=>"3"
   #     },

    let(:params) do
        {
            :title    => 'Audit: Audit the use of Backup and Restore privilege',
            :ensure   => 'present',
            :regvalue => 0,
            :provider => :so_registryvalue,
        }
    end

    let(:resource) do
        Puppet::Type.type(:so_registryvalue).new(params)
    end
    let (:hashresource) do
      [params].each_with_object({}) do |params1, h| 
          h[params1[:title]] = Puppet::Type.type(:so_registryvalue).new(params1) 
      end 

    end
    #@provider = provider.new(resource)
    #resource.provider = @provider


    let(:provider) do
        resource.provider
    end

    let(:cachedir) do
      'C:\ProgramData\PuppetLabs\Puppet\cache'
    end

    let(:out_file) do
        File.join(cachedir, '/rvsecurityoptionsoutput.txt').gsub('/', '\\')
    end

    def stub_secedit_export
        ini_stub = Puppet::Util::IniFile.new(File.join(
        File.dirname(__FILE__), "../../../../fixtures/unit/puppet/provider/so_registryvalue/so_registryvalue/rvsecurityoptionsoutput.txt"), '=')
        myfile=File.join(
        File.dirname(__FILE__), "../../../../fixtures/unit/puppet/provider/so_registryvalue/so_registryvalue/rvsecurityoptionsoutput.txt")
        #$stderr.puts ini_stub.get_settings('Registry Values')
        $stderr.puts myfile 
        expect(Puppet).to receive(:[]).at_least(:once).with(:cachedir).and_return('C:\ProgramData\PuppetLabs\Puppet\cache')
        expect(File).to receive(:open).at_least(:once).with(out_file, 'w')
        expect(provider.class).to receive(:secedit).at_least(:once).with('/export', '/cfg', out_file, '/areas', 'securitypolicy')
        expect(Puppet::Util::IniFile).to receive(:new).at_least(:once).with(out_file, '=')
            .and_return(ini_stub)
    end

    describe "responds to" do
      [:exists?, :create, :destroy, :regvalue, :regvalue=].each { |method|
        it { is_expected.to respond_to(method) }
      }
    end

    describe 'exists' do
        before(:each) do
          stub_secedit_export
          @instances = provider.class.instances.map do |i| {
            :name     => i.get(:name),
            :ensure   => i.get(:ensure),
            :regvalue => i.get(:regvalue),
            }
          end
        end


      it 'exists' do
        #provider.class.instances
        catalog = Puppet::Resource::Catalog.new
        catalog.add_resource resource
        provider.class.prefetch(hashresource)
      end
    end


    context 'when listing instances' do
        before(:each) do
          stub_secedit_export
          @instances = provider.class.instances.map do |i| {
            :name     => i.get(:name),
            :ensure   => i.get(:ensure),
            :regvalue => i.get(:regvalue),
            }
          end
        end
        it 'doing example1' do
          example1=@instances.find { |p| p[:name].downcase == "Interactive logon: Smart card removal behavior".downcase}
          expect(example1).to eq({
            :name   => 'Interactive logon: Smart card removal behavior',
            :ensure => :present,
            :regvalue => "\"1\"",
          })
        end
        it 'doing example3' do
          example3=@instances.find { |p| p[:name].downcase == "Audit: Audit the use of Backup and Restore privilege".downcase}
          expect(example3).to eq({
            :name   => 'Audit: Audit the use of Backup and Restore privilege',
            :ensure => :present,
            :regvalue => 0,
          })

        end
        it 'doing sampel4' do
          example4=@instances.find { |p| p[:name].downcase == "Recovery console: Allow automatic administrative logon".downcase}
          expect(example4).to eq({
            :name   => 'Recovery console: Allow automatic administrative logon',
            :ensure => :present,
            :regvalue => 0,
          })
        end
        it 'doing sample 7a' do
          example7a=@instances.find { |p| p[:name].downcase == "System settings: Optional subsystems".downcase}
          expect(example7a).to eq({
            :name   => 'System settings: Optional subsystems',
            :ensure => :present,
            :regvalue => [],
          })
        end
        it 'doing example 7b' do
          example7b=@instances.find { |p| p[:name].downcase == "Interactive logon: Message text for users attempting to log on".downcase}
          expect(example7b).to eq({
            :name   => 'Interactive logon: Message text for users attempting to log on',
            :ensure => :present,
            :regvalue => ["By logging in I understand that the information on this computer and network system is Company property protected by law and that it may be accessed and used only by authorized personel and that my use may be monitored."],
          })
        end
        it 'doing sample 7c' do
          example7c=@instances.find { |p| p[:name].downcase == "Network access: Remotely accessible registry paths and sub-paths".downcase}
          expect(example7c).to eq({
            :name   => 'Network access: Remotely accessible registry paths and sub-paths',
            :ensure => :present,
            :regvalue => ["System\\CurrentControlSet\\Control\\Print\\Printers", "System\\CurrentControlSet\\Services\\Eventlog", "Software\\Microsoft\\OLAP Server", "Software\\Microsoft\\Windows NT\\CurrentVersion\\Print", "Software\\Microsoft\\Windows NT\\CurrentVersion\\Windows", "System\\CurrentControlSet\\Control\\ContentIndex", "System\\CurrentControlSet\\Control\\Terminal Server", "System\\CurrentControlSet\\Control\\Terminal Server\\UserConfig", "System\\CurrentControlSet\\Control\\Terminal Server\\DefaultUserConfiguration", "Software\\Microsoft\\Windows NT\\CurrentVersion\\Perflib", "System\\CurrentControlSet\\Services\\SysmonLog"],
          })

        end
        it 'should list all instances' do

      #it 'should find all instances' do
          expect(@instances.size).to eq(72)
      #it 'should populate the instances correctly' do
        end
    end
end

