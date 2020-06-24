Puppet::Type.newtype(:so_privilegerights_fragment) do
    @doc = <<-'EOT'
    Append users to a so_privilegerights resource.
    EOT

    newparam(:name, :namevar => true) do
        desc 'The mandatory namevar...just name it however you want'
    end

    newparam(:right) do
        desc 'The right to append users to...long displayname from secedit_mapping.json'

        validate do |value|
           raise ArgumentError,  "Invalid display name: '#{value}'" unless PuppetX::Securityoptions::Mappingtables.new.valid_displayname?(value,'PrivilegeRights')
       #     fail "Not a valid right name: '#{value}'" unless value =~ /^[A-Za-z\s]+$/
       #   raise ArgumentError, "Invalid right name: \'#{value}\'" unless PuppetX::Securityoptions::Mappingtables.new.valid_name?(value,'PrivilegeRights')
        end

        munge do |value|
            value.downcase
        end
    end

    newparam(:sid, :array_matching => :all) do

        desc 'List of SIDs to append to the right'
        #...well no exactly SIDs --> COPR\Administrators
        # do we want to validate it somehow?
    end
end
