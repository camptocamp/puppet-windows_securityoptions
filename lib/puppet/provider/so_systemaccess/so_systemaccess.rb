require 'pathname'

require File.join(File.dirname(__FILE__), '../../../puppet/provider/windows_securityoptions')

Puppet::Type.type(:so_systemaccess).provide(:so_systemaccess, parent: Puppet::Provider::Windows_SecurityOptions) do
  require Pathname.new(__FILE__).dirname + '../../../puppet_x/securityoptions/secedit_mapping'
  defaultfor osfamily: :windows
  confine osfamily: :windows

  commands secedit: 'secedit.exe'

  attr_so_accessor(:sovalue)

  def write_export_filename
    'soimports'
  end

  def map_option(securityoption)
    res_mapping = PuppetX::Securityoptions::Mappingtables.new.get_mapping(securityoption, 'SystemAccess')
    res_mapping['name']
  end

  def section_name
    'System Access'
  end

  def self.instances
    secedit_exports.get_settings('System Access').map do |k, v|
      res_displayname = PuppetX::Securityoptions::Mappingtables.new.get_displayname(k, 'SystemAccess')
      res_mapping = PuppetX::Securityoptions::Mappingtables.new.get_mapping(res_displayname, 'SystemAccess')

      if res_mapping['data_type'] == 'integer'
        value = v.to_i
      elsif res_mapping['data_type'] == 'qstring'
        value = v
      end

      new(name: res_displayname,
          ensure: :present,
          sovalue: value)
    end
  end
end
