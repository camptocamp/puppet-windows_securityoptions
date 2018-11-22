require 'pathname'

Puppet::Type.newtype(:so_privilegerights) do
    require Pathname.new(__FILE__).dirname + '../../puppet_x/securityoptions/secedit_mapping'
    @doc = <<-'EOT'
    Manage a Windows User Rights Assignment.
    EOT

    ensurable do
        defaultvalues

        defaultto { :present }
    end

    newparam(:name, :namevar => true) do
        desc 'The long name of the privilege right as it shows up in the local security policy'

        validate do |value|
            raise ArgumentError,  "Invalid display name: '#{value}'" unless PuppetX::Securityoptions::Mappingtables.new.valid_name?(value,'PrivilegeRights')
        end

        munge do |value|
            value.downcase
        end
    end

    newproperty(:sid, :array_matching => :all) do
        desc 'List of SIDs to allow for this right'

        def fragments
            # Collect fragments that target this resource by name or title.
            @fragments ||= resource.catalog.resources.map { |res|
                next unless res.is_a?(Puppet::Type.type(:user_rights_assignment))

                if res[:right] == @resource[:name] || res[:right] == @resource[:title]
                    res
                end
            }.compact
        end

        def should
            values = super

            fragments.each do |f|
                values << f[:sid]
            end

            values.compact
        end

        def insync?(current)
            provider.sid_in_sync?(current, @should)
        end
    end
end
