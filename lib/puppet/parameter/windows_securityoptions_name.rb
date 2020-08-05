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
    raise ArgumentError, "Invalid name: '#{value}'" unless valid_name?(value)
  end

  def valid_name?(value)
    cat = self.class.category.to_s
    return PuppetX::Securityoptions::Mappingtables.new.valid_name?(value, cat) \
      if cat == :PrivilegeRights

    PuppetX::Securityoptions::Mappingtables.new.valid_displayname?(value, cat)
  end

  munge do |value|
    value.downcase
  end
end
