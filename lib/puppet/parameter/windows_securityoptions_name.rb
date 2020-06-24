require Pathname.new(__FILE__).dirname + '../../puppet_x/securityoptions/secedit_mapping'
class Puppet::Parameter::Windows_SecurityOptions_Name < Puppet::Parameter
  validate do |value|
    raise ArgumentError,  "Invalid display name: '#{value}'" unless PuppetX::Securityoptions::Mappingtables.new.valid_displayname?(value,'PrivilegeRights')
  end

  munge do |value|
    value.downcase
  end
end
