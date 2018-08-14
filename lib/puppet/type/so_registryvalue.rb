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

    newparam(:name, :namevar => true) do
    #    desc 'The long name of the setting as it shows up in the local security policy'
    #  validate do |value|
    #    raise ArgumentError, "Invalid Policy name: #{value}" unless Mappingtables.registry_valid_name?(value)
    #  end
#
    end
#
    newproperty(:regvalue) do
#        desc 'the value for the setting'
#
    end
end
