require 'puppet/parameter/windows_securityoptions_name'

Puppet::Type.newtype(:so_privilegerights_fragment) do
  @doc = <<-'EOT'
    Append users to a so_privilegerights resource.  This type functions similar to the concat type that allows fragments to be inserted into the catalog and then used by the so_privilegerights provider.  This allows for authors of profiles to add the necessary user right assignments needed by their profile without having to add hiera data to roles.
    EOT

  newparam(:name, namevar: true) do
    desc 'The mandatory namevar...just name it however you want'
  end

  newparam(:right, parent: Puppet::Parameter::Windows_SecurityOptions_Name) do
    category { :PrivilegeRights }
    desc 'The right to append users to.  This is the shortname of the user right, for example: sesyncagentprivilege'
  end

  newparam(:sid, array_matching: :all) do
    desc 'List of security object to append to the user right assignment.  This is any security object that has an SID, eg user, group, service account.'
    # ...well no exactly SIDs --> COPR\Administrators
    # do we want to validate it somehow?
  end
end
