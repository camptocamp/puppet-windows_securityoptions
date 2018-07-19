require 'spec_helper'
require 'stringio'

describe Puppet::Type.type(:user_right).provider(:secedit) do
    let(:params) do
        {
            :title    => 'seincreasequatoprivilege',
            :ensure   => 'present',
            :sid      => 'CORP\admin',
            :provider => :secedit,
        }
    end

    let(:resource) do
        Puppet::Type.type(:user_right).new(params)
    end

    let(:provider) do
        resource.provider
    end

    let(:vardir) do
      'C:\ProgramData\PuppetLabs\Puppet\var'
    end

    let(:out_file) do
        File.join(vardir, '/secedit_import.txt').gsub('/', '\\')
    end

    def stub_secedit_export
        ini_stub = Puppet::Util::IniFile.new(File.join(
        File.dirname(__FILE__), "../../../../fixtures/unit/puppet/provider/user_right/secedit/full.txt"), '=')

        expect(Puppet).to receive(:[]).once.with(:vardir).and_return('C:\ProgramData\PuppetLabs\Puppet\var')
        expect(File).to receive(:open).once.with(out_file, 'w')
        expect(provider.class).to receive(:secedit).with('/export', '/cfg', out_file, '/areas', 'user_rights')
        expect(Puppet::Util::IniFile).to receive(:new).once.with(out_file, '=')
            .and_return(ini_stub)
    end

    context 'when listing instances' do
        it 'should list instances' do
            stub_secedit_export
            instances = provider.class.instances.map do |i| {
                :name   => i.get(:name),
                :ensure => i.get(:ensure),
                :sid    => i.get(:sid),
            }
            end
            expect(instances.size).to eq(32)
            expect(instances[0]).to eq({
                :name   => 'SeNetworkLogonRight',
                :ensure => :present,
                :sid    => ['*S-1-5-11', '*S-1-5-32-544'],
            })
        end
    end
end
