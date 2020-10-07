require 'puppet/parameter/windows_securityoptions_name'

Puppet::Type.newtype(:so_privilegerights) do
  @doc = <<-'EOT'
    Manages a Windows User Rights Assignment.  User Right Assignments determine what a particular security object is allowed to do an a Windows Server.
    EOT

  ensurable do
    defaultvalues

    defaultto { :present }
  end

  newparam(:name, namevar: true, parent: Puppet::Parameter::Windows_SecurityOptions_Name) do
    category { :PrivilegeRights }

    desc 'The shortname of the user right assignment.'
  end

  newproperty(:sid, array_matching: :all) do
    desc 'List of security objects to allow for this right'

    def fragments
      # Collect fragments that target this resource by name or title.
      # the user_rigth_assignment is an old type that is being phased out
      # this will be removed in future versions
      @fragments ||= resource.catalog.resources.map { |res|
        next unless
  res.is_a?(Puppet::Type.type(:so_privilegerights_fragment)) ||
  res.is_a?(Puppet::Type.type(:user_right_assignment))

        if res[:right] == @resource[:name]
          res
        end
      }.compact
    end

    def should
      values = super

      fragments.each do |f|
        values << f[:sid]
      end

      values.flatten.compact
    end

    def insync?(current_sids)
      return false unless current_sids
      specified_sids = provider.name_to_sid(@should)
      specified_sids.sort == current_sids.sort
    end
  end
end
