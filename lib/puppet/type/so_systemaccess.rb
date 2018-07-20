require 'pathname'

Puppet::Type.newtype(:so_systemaccess) do
    require Pathname.new(__FILE__).dirname + '../../puppet_x/security_options/mappingtables'
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
        raise ArgumentError, "Invalid Policy name: #{value}" unless Mappingtables.system_valid_name?(value)
      end

    end

    newproperty(:sovalue) do
      desc 'the value for the setting'
      validate do |value|
        datatype = Mappingtables.get_system_datatype(resource[:name])
        if datatype == 'integer' then
          raise ArgumentError, "Invalid value: #{value}.  This must be a number" unless  value.is_a?(Integer)
        elsif datatype == 'string' then
          raise ArgumentError, "Invalid value: #{value}.  This must be a quoted string" unless value.is_a?(String)
        else 
          raise ArgumentError, "Invalid DataType: #{value} in Mappingtables" 
        end

      end
      munge do |value|
        datatype = Mappingtables.get_system_datatype(resource[:name])
        if datatype == 'integer' then
          value.to_i
        end
      end

    end
end
