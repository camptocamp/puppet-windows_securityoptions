require 'pathname'
require 'puppet/parameter/windows_securityoptions_name'

Puppet::Type.newtype(:so_registryvalue) do
  require Pathname.new(__FILE__).dirname + '../../puppet_x/securityoptions/secedit_mapping'
  @doc = <<-'EOT'
    Manage a Windows User Rights Assignment.
    EOT

  ensurable do
    defaultvalues
    defaultto { :present }
  end

  newparam(:name, namevar: true, parent: Puppet::Parameter::Windows_SecurityOptions_Name) do
    category { :RegistryValues }

    desc 'The long name of the setting as it shows up in the local security policy'
  end

  newproperty(:sovalue) do
    desc 'the value of the registry setting'

    validate do |value|
      res_mapping = PuppetX::Securityoptions::Mappingtables.new.get_mapping(resource[:name], 'RegistryValues')
      Puppet.debug res_mapping
      if res_mapping['reg_type'] == '4'
        raise ArgumentError, "Invalid value: \'#{value}\'.  This must be a number" unless begin
                                                                                             Integer(value)
                                                                                           rescue
                                                                                             false
                                                                                           end
      elsif res_mapping['reg_type'] == '1'
        raise ArgumentError, "Invalid value: \'#{value}\'.  This must be a quoted string" unless value.to_s
      elsif res_mapping['reg_type'] == '3'
        raise ArgumentError, "Invalid value: \'#{value}\'.  This must be a 1 or 0" unless value.to_i == 0 || value.to_i == 1
      elsif res_mapping['reg_type'] == '7'
        raise ArgumentError, "Invalid value: \'#{value}\'.  This must be an array" unless Array(value) || value.nil?
      else
        raise ArgumentError, "Invalid DataType: \'#{res_mapping['reg_type']}\' in Mappingtables"
      end
    end

    munge do |value|
      res_mapping = PuppetX::Securityoptions::Mappingtables.new.get_mapping(resource[:name], 'RegistryValues')
      if res_mapping['reg_type'] == '4'
        return value.to_i
      elsif res_mapping['reg_type'] == '1'
        value = value.to_s
        return '"' + value.tr('"', '') + '"'
      elsif res_mapping['reg_type'] == '7'
        return '' if value.nil?
        value = value.to_s
        return value
      end
    end
  end
end
