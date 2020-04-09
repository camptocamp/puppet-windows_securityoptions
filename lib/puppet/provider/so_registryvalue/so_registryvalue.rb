require 'pathname'

require File.join(File.dirname(__FILE__), '../../../puppet/provider/windows_securityoptions')

Puppet::Type.type(:so_registryvalue).provide(:so_registryvalue, parent: Puppet::Provider::Windows_SecurityOptions) do
    require Pathname.new(__FILE__).dirname + '../../../puppet_x/securityoptions/secedit_mapping'
    defaultfor :osfamily => :windows
    confine :osfamily => :windows

    commands :secedit => 'secedit.exe'

    attr_so_accessor(:sovalue)

    def write_export_filename
      'soimports'
    end

    def section_name
      'Registry Values'
    end

    def map_option(securityoption)
      res_mapping = PuppetX::Securityoptions::Mappingtables.new.get_mapping(securityoption, 'RegistryValues')
      res_mapping['name']
    end

    def map_value(securityoption, value)
      res_mapping = PuppetX::Securityoptions::Mappingtables.new.get_mapping(securityoption, 'RegistryValues')
      [res_mapping['reg_type'], value]
    end

    def self.prefetch(resources)
        instances.each do |right|
            resources.select { |title, res|
                res[:name].downcase == right.get(:name).downcase
            }.map { |name, res|
                res.provider = right
            }
        end
    end

    def self.instances
      secedit_exports.get_settings('Registry Values').map { |k, v|
        res_displayname = PuppetX::Securityoptions::Mappingtables.new.get_displayname(k, 'RegistryValues')
        res_mapping     = PuppetX::Securityoptions::Mappingtables.new.get_mapping(res_displayname, 'RegistryValues')
        Puppet.debug(res_displayname)
        Puppet.debug(res_mapping)
        value = (v.split(',')[1..-1]).join(',')
        Puppet.debug(value)
        if res_mapping['reg_type'] == '3' || res_mapping['reg_type'] == '4' then
          value = value.to_i
        elsif res_mapping['reg_type'] == '7' then
          value = value || ''
        elsif res_mapping['reg_type'] == '4' then
        end

        new({
          :name      => res_displayname,
          :ensure    => :present,
          :sovalue   => value,
        })
      }

   end

end
