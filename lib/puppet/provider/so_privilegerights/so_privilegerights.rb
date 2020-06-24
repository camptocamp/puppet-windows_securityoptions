require 'puppet/util/windows'

require File.join(File.dirname(__FILE__), '../../../puppet/provider/windows_securityoptions')

Puppet::Type.type(:so_privilegerights).provide(:so_privilegerights, parent: Puppet::Provider::Windows_SecurityOptions) do
  defaultfor osfamily: :windows
  confine osfamily: :windows

  commands secedit: 'secedit.exe'

  attr_so_accessor(:sid)

  def write_export_filename
    'secedit_export'
  end

  def section_name
    'Privilege Rights'
  end

  def name_to_sid(users)
    users.map { |user| '*' + Puppet::Util::Windows::SID.name_to_sid(user) }
  end

  def map_value(value)
    name_to_sid(value)
  end

  def self.instances
    secedit_exports.get_settings('Privilege Rights').map do |k, v|
      new(name: k,
          ensure: :present,
          sid: v.split(','))
    end
  end
end
