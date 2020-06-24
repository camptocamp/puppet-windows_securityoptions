require 'puppet/parameter/windows_securityoptions_name'

Puppet::Type.newtype(:user_rights_assignment) do
    @doc = <<-'EOT'
    Append users to a so_privilegerights resource.
    EOT

    newparam(:name, :namevar => true) do
        desc 'The mandatory namevar...just name it however you want'
    end

    newparam(:right, :parent => Puppet::Parameter::Windows_SecurityOptions_Name) do
        desc 'The right to append users to...long displayname from secedit_mapping.json'
    end

    newparam(:sid) do
        desc 'List of SIDs to append to the right'
        #...well no exactly SIDs --> COPR\Administrators
        # do we want to validate it somehow?
    end
end
