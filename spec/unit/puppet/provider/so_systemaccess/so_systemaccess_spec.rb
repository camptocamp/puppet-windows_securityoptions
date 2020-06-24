require 'spec_helper'
require 'stringio'
require 'puppet/util'
require 'pathname'

begin
  require File.expand_path('../../../util/ini_file', __FILE__)
rescue LoadError

  # in case we're not in libdir
  require File.expand_path('../../../../../spec/fixtures/modules/inifile/lib/puppet/util/ini_file', __FILE__) if File.file?('../../../../../spec/fixtures/modules/inifile/lib/puppet/util/ini_file')
end


describe Puppet::Type.type(:so_systemaccess).provider(:so_systemaccess) do

    let(:params) do
        {
            :title    => 'Enforce password history',
            :ensure   => 'present',
            :sovalue => 24,
            :provider => :so_systemaccess,
        }
    end

    let(:resource) do
        Puppet::Type.type(:so_systemaccess).new(params)
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
        File.join(vardir, '/secedit.sdb').gsub('/', '\\')
    end

    def stub_secedit_export
        ini_stub = Puppet::Util::IniFile.new(File.join(File.dirname(__FILE__), "../../../../../lib/puppet_x/securityoptions/securityoptionsoutput.txt"), '=')
        expect(provider.class).to receive(:secedit_exports).at_least(:once)
            .and_return(ini_stub)
    end

    context "when checking standard methods" do
      [:exists?, :create, :destroy, :sovalue, :sovalue=].each { |method|
        it { is_expected.to respond_to(method) }
      }
    end

    context "when using prefetch" do
        it 'should not exist before prefetch' do
            expect(resource.provider.exists?).to eq(false)
            expect(resource.provider.sovalue).to eq(nil)
        end

        it 'should exist after prefetch' do
            stub_secedit_export
            provider.class.prefetch(hashresource)
            expect(resource.provider.exists?).to eq(true)
            expect(resource.provider.sovalue).to eq(24)
        end
    end


    context 'when listing instances' do
        before(:each) do
          stub_secedit_export
          @instances = provider.class.instances.map do |i| {
            :name     => i.get(:name),
            :ensure   => i.get(:ensure),
            :sovalue => i.get(:sovalue),
            }
          end
        end

        it 'should list all instances' do
          expect(@instances.size).to eq(16)
        end

        it 'should find Accounts: Rename guest account (qstring)' do
          example1 = @instances.find { |p|
              p[:name].downcase == "Accounts: Rename guest account".downcase
          }
          expect(example1).to eq({
            :name   => 'Accounts: Rename guest account',
            :ensure => :present,
            :sovalue => "\"Guest_Disabled\"",
          })
        end

        it 'should find Network security: Force logoff when logon hours expire (integer)' do
          example2 = @instances.find { |p|
              p[:name].downcase == "Network security: Force logoff when logon hours expire".downcase
          }
          expect(example2).to eq({
            :name   => 'Network security: Force logoff when logon hours expire',
            :ensure => :present,
            :sovalue => 0,
          })

        end

    end

    def stub_write_export(value)
        expect(Puppet).to receive(:[]).at_least(:once).with(:vardir).and_return(vardir)
        expect(Dir).to receive(:mkdir).at_least(:once).with(File.join(vardir, 'soimports'))
        writeFile = StringIO.new
        expect(File).to receive(:open).at_least(:once).with("C:\\ProgramData\\PuppetLabs\\Puppet\\cache\\soimports\\enforcepasswordhistory.txt", 'w').and_yield(writeFile)
        expect(writeFile).to receive(:write).with("[Unicode]
Unicode=yes
[System Access]
PasswordHistorySize = #{value}
[Version]
signature=\"$CHICAGO$\"
Revision=1
")
    end

    def stub_flush(path)
        expect(provider.class).to receive(:secedit).at_least(:once).with('/configure', '/db', tmp_sdb_file, '/cfg', path)
    end

    context 'when updating value' do
        it 'should update value' do
            stub_write_export(12)
            expect(provider.sovalue).to eq(nil)
            provider.sovalue=12
            expect(provider.sovalue).to eq(12)
            stub_flush("C:\\ProgramData\\PuppetLabs\\Puppet\\cache\\soimports\\enforcepasswordhistory.txt")
            provider.flush
        end
    end
end

