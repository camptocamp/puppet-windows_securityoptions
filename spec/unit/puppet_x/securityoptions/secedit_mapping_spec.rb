require 'spec_helper'
require 'puppet_x/securityoptions/secedit_mapping'
#require 'ruby-debugger'

describe PuppetX::Securityoptions::Mappingtables do
  let(:saname)        { 'ClearTextPassword' }
  let(:sadisplayname) { 'Store passwords using reversible encryption' }
  let(:rvname)        { 'MACHINE\\System\\CurrentControlSet\\Control\\Lsa\\RestrictAnonymousSAM' }
  let(:rvdisplayname) { 'Network access: Do not allow anonymous enumeration of SAM accounts' }

  #let(:samplejsonpath) { File.join(File.dirname(__FILE__), '..', '..', '..', 'fixtures', 'unit', 'puppet_x', 'securityoptions')}
  #let(:samplejsonname) {'secedit_mapping.sample.json'}
  #let (:samplejson) do
  #  File.expand_path(File.join(samplejsonpath,samplejsonname))
  #end

  let(:hashfromjson) {
    {
     "SystemAccess" => 
      [
        {"displayname"=>"Enforce password history", 
         "name"=>"PasswordHistorySize", 
         "data_type"=>"integer"
        },
        {"displayname"=>"Accounts: Rename administrator account",
         "name"=>"NewAdministratorName",
         "data_type"=>"qstring"
        }
      ], 
     "RegistryValues" =>
      [
        {"displayname"=>"Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings",
         "name"=>"MACHINE\\System\\CurrentControlSet\\Control\\Lsa\\SCENoApplyLegacyAuditPolicy",
         "reg_type"=>"4"
        },
        {"displayname"=>"System settings: Optional subsystems",
         "name"=>"MACHINE\\System\\CurrentControlSet\\Control\\Session Manager\\SubSystems\\optional",
         "reg_type"=>"7"
        },
        {"displayname"=>"Audit: Audit the use of Backup and Restore privilege",
         "name"=>"MACHINE\\System\\CurrentControlSet\\Control\\Lsa\\FullPrivilegeAuditing",
         "reg_type"=>"3"
        },
        {"displayname"=>"Interactive logon: Message title for users attempting to log on",
         "name"=>"MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System\\LegalNoticeCaption",
         "reg_type"=>"1"
        }
      ]
    }

  }


  mapping_instance = described_class.new

  it 'check for valid displayname' do
    expect(mapping_instance.valid_name?(rvdisplayname,'RegistryValues')).to be_truthy
  end
  it 'check for valid name' do
    expect(mapping_instance.get_displayname(rvname,'RegistryValues')).to eq(rvdisplayname)
  end
  it 'correctly parses json file' do
    hashfromfile = mapping_instance.get_mapping('System settings: Optional subsystems','RegistryValues')
    expect(hashfromfile['displayname']).to eq('System settings: Optional subsystems')
    expect(hashfromfile['name']).to eq('MACHINE\\System\\CurrentControlSet\\Control\\Session Manager\\SubSystems\\optional')
    expect(hashfromfile['reg_type']).to eq('7')

  end

end
