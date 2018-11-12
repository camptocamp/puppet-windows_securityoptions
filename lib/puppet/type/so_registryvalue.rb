require 'pathname'

Puppet::Type.newtype(:so_registryvalue) do
    require Pathname.new(__FILE__).dirname + '../../puppet_x/securityoptions/secedit_mapping'
    @doc = <<-'EOT'
    Manage a Windows User Rights Assignment.
    EOT

    ensurable do
        defaultvalues
        defaultto { :present }
    end

    #newparam(:name, :namevar => true) do
    newparam(:name, :namevar => true) do
    #    desc 'The long name of the setting as it shows up in the local security policy'
      validate do |value|
        raise ArgumentError, "Invalid Policy name: \'#{value}\'" unless PuppetX::Securityoptions::Mappingtables.new.valid_name?(value,'RegistryValues')
      end
#
    end
#
    newproperty(:sovalue) do
      desc "the value of the registry setting" 

      validate do |value|

        res_mapping = PuppetX::Securityoptions::Mappingtables.new.get_mapping(resource[:name], 'RegistryValues')
        Puppet.debug res_mapping
        if res_mapping['reg_type'] == '4' then
          raise ArgumentError, "Invalid value: \'#{value}\'.  This must be a number" unless (Integer(value) rescue false)
        elsif res_mapping['reg_type'] == '1' then
          raise ArgumentError, "Invalid value: \'#{value}\'.  This must be a quoted string" unless value.to_s
        elsif res_mapping['reg_type'] == '3' then
          raise ArgumentError, "Invalid value: \'#{value}\'.  This must be a 1 or 0" unless (value.to_i == 0 or value.to_i == 1)
        elsif res_mapping['reg_type'] == '7' then
          raise ArgumentError, "Invalid value: \'#{value}\'.  This must be an array" unless ( Array(value) or value.nil? )
        else
          raise ArgumentError, "Invalid DataType: \'#{res_mapping['reg_type']}\' in Mappingtables"
        end
      end

      munge do |value|
        res_mapping = PuppetX::Securityoptions::Mappingtables.new.get_mapping(resource[:name], 'RegistryValues')
        if res_mapping['reg_type'] == '4' then
          return value.to_i 
        elsif res_mapping['reg_type'] == '1' then
          value = value.to_s 
          return "\"" + value.tr('"', '') + "\""
        elsif res_mapping['reg_type'] == '7' then
          return '' if value.nil?
          value = value.to_s
          return value 
        end
      end
    end
end
