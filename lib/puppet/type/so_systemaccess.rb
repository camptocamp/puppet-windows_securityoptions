require 'pathname'

Puppet::Type.newtype(:so_systemaccess) do
    require Pathname.new(__FILE__).dirname + '../../puppet_x/securityoptions/secedit_mapping'
    @doc = <<-'EOT'
    Manage a Windows User Rights Assignment.
    EOT

    ensurable do
        defaultvalues
        defaultto { :present }
    end

    newparam(:name, :namevar => true) do
      desc 'The long name of the setting as it shows up in the local security policy'
      validate do |value|
        raise ArgumentError, "Invalid Policy name: \'#{value}\'" unless PuppetX::Securityoptions::Mappingtables.new.valid_name?(value,'SystemAccess')
      end

    end

    newproperty(:sovalue) do
      desc 'the value for the setting'
      #validate do |val|


      #Puppet.debug "resource name"
      #Puppet.debug resource[:name]
      #Puppet.debug "resource name"
      #end
      validate do |value|
        mapping = PuppetX::Securityoptions::Mappingtables.new
        res_mapping      = mapping.get_mapping(resource[:name], 'SystemAccess')
   
        if res_mapping['data_type'] == 'integer' then
          raise ArgumentError, "Invalid value: \'#{value}\'.  This must be a number" unless (Integer(value) rescue false)
        elsif res_mapping['data_type'] == 'qstring' then
          raise ArgumentError, "Invalid value: \'#{value}\'.  This must be a quoted string" unless value.to_s
        elsif res_mapping['data_type'] != 'integer' and res_mapping['data_type'] != 'qstring' 
          raise ArgumentError, "Invalid DataType: \'#{value}\' in Mappingtables" 
        end

      end
      munge do |value|
        mapping = PuppetX::Securityoptions::Mappingtables.new
        #res_display_name = PuppetX::Securityoptions::Mappingtables.get_displayname(resource[:name])
        #res_mapping      = PuppetX::Securityoptions::Mappingtables.get_mapping(res_display_name, 'SystemAccess')
        res_mapping      = mapping.get_mapping(resource[:name], 'SystemAccess')
        if res_mapping['data_type'] == 'integer' then
          return value.to_i
        elsif res_mapping['data_type'] == 'qstring' then
          value = value.to_s 
          value = "\"" + value.tr('"', '') + "\""
          return value
        end
      end

    end
end
