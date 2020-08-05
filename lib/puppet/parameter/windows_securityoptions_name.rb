require Pathname.new(__FILE__).dirname + '../../puppet_x/securityoptions/secedit_mapping'

class Puppet::Parameter::Windows_SecurityOptions_Name < Puppet::Parameter
  def self.category(&block)
    if block_given?
      cat = block.call
      raise ArgumentError, "Invalid Windows Security Options category '#{cat}'" unless [:PrivilegeRights, :RegistryValues, :SystemAccess].include?(cat)
      @category = cat
    end

    @category
  end

  def unsafe_validate(value)
    cat = self.class.category

    if cat == :PrivilegeRights
      raise ArgumentError, "Invalid name: '#{value}'" \
        unless PuppetX::Securityoptions::Mappingtables.new.valid_name?(value, cat.to_s)
    else
      raise ArgumentError, "Invalid display name: '#{value}'" \
        unless PuppetX::Securityoptions::Mappingtables.new.valid_displayname?(value, cat.to_s)
    end
  end

  munge do |value|
    value.downcase
  end
end
