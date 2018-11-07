require 'puppet/util/windows'
require 'pathname'

begin
  require File.expand_path('../../../util/ini_file', __FILE__)
rescue LoadError
  # in case we're not in libdir
  require File.expand_path('../../../../../spec/fixtures/modules/inifile/lib/puppet/util/ini_file', __FILE__)
end

Puppet::Type.type(:so_registryvalue).provide(:so_registryvalue) do
    require Pathname.new(__FILE__).dirname + '../../../puppet_x/securityoptions/secedit_mapping'
    defaultfor :osfamily => :windows
    confine :osfamily => :windows

    commands :secedit => 'secedit.exe'

    def exists?
        @property_hash[:ensure] == :present
    end

    def create
        write_export(@resource[:name], @resource[:regvalue])
        @property_hash[:ensure] = :present
    end

    def destroy
        write_export(@resource[:name], [])
        @property_hash[:ensure] = :absent
    end

    def regvalue 
        @property_hash[:regvalue]
    end

    def regvalue=(value)
        write_export(@resource[:name], value)
        @property_hash[:regvalue] = value
    end

    def in_file_path(securityoption)
        File.join(Puppet[:cachedir], 'rvimports', "#{securityoption}.txt").gsub('/', '\\')
    end

    def write_export(securityoption, value)

        dir = File.join(Puppet[:cachedir], 'rvimports')
        Dir.mkdir(dir) unless Dir.exist?(dir)

        File.open(in_file_path(securityoption), 'w') do |f|
          f.write <<-EOF
[Unicode]
Unicode=yes
[Registry Values]
#{securityoption} = #{value}
[Version]
signature="$CHICAGO$"
Revision=1
          EOF
        end
    end

    def flush
        secedit('/configure', '/db', 'secedit.sdb', '/cfg', in_file_path(@resource[:name]))
    end


    #def sid_in_sync?(current, should)
    #    return false unless current
    #    current_sids = current
    #    specified_sids = name_to_sid(should)
    #    Puppet.debug specified_sids.to_json
    #    (specified_sids & current_sids) == (specified_sids | current_sids)
    #end

    def self.prefetch(resources)
        instances.each do |right|
            resources.select { |title, res|
                res[:name].downcase == right.get(:name).downcase
            }.map { |name, res|
                res.provider = right
            }
        end
    end

    def self.instances
        out_file_path = File.join(Puppet[:cachedir], 'rvsecurityoptionsoutput.txt').gsub('/', '\\')
        # Once the file exists in UTF-8, secedit will also use UTF-8
        File.open(out_file_path, 'w') { |f| f.write('# We want UTF-8') }
        secedit('/export', '/cfg', out_file_path, '/areas', 'securitypolicy')
        return getregistryvalues(out_file_path) 
    end

   def self.getregistryvalues(out_file_path)
      ini = Puppet::Util::IniFile.new(out_file_path, '=')
      ini.get_settings('Registry Values').map { |k, v|
        res_displayname = PuppetX::Securityoptions::Mappingtables.new.get_displayname(k, 'RegistryValues')
        res_mapping     = PuppetX::Securityoptions::Mappingtables.new.get_mapping(res_displayname, 'RegistryValues')

        value = (v.split(',')[1..-1]).join(',')
        if res_mapping['reg_type'] == '3' || res_mapping['reg_type'] == '4' then
          value = value.to_i
        elsif res_mapping['reg_type'] == '7' then
          value = value.split(',')
        elsif res_mapping['reg_type'] == '4' then
        end

        new({
          :name      => res_displayname,
          :ensure    => :present,
          :regvalue   => value,
        })
      }

   end

end
