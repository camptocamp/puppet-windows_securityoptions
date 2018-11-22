require 'puppet/util/windows'
require 'pathname'

begin
  require File.expand_path('../../../util/ini_file', __FILE__)
rescue LoadError

  # in case we're not in libdir
  require File.expand_path('../../../../../spec/fixtures/modules/inifile/lib/puppet/util/ini_file', __FILE__) if File.file?('../../../../../spec/fixtures/modules/inifile/lib/puppet/util/ini_file.rb')
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
        write_export(@resource[:name], @resource[:sovalue])
        @property_hash[:ensure] = :present
    end

    def destroy
        write_export(@resource[:name], [])
        @property_hash[:ensure] = :absent
    end

    def sovalue 
        @property_hash[:sovalue]
    end

    def sovalue=(value)
        write_export(@resource[:name], value)
        @property_hash[:sovalue] = value
    end

    def in_file_path(securityoption)
        securityoption = securityoption.scan(/[\da-z]/i).join
        File.join(Puppet[:vardir], 'soimports', "#{securityoption}.txt").gsub('/', '\\')
    end

    def write_export(securityoption, value)
        res_mapping = PuppetX::Securityoptions::Mappingtables.new.get_mapping(securityoption, 'RegistryValues')

        dir = File.join(Puppet[:vardir], 'soimports')
        Dir.mkdir(dir) unless Dir.exist?(dir)

        File.open(in_file_path(securityoption), 'w') do |f|
          f.write <<-EOF
[Unicode]
Unicode=yes
[Registry Values]
#{res_mapping['name']} = #{res_mapping['reg_type']},#{value}
[Version]
signature="$CHICAGO$"
Revision=1
          EOF
        end
    end

    def flush
        tmp_sdb_file = File.join(Puppet[:vardir], 'secedit.sdb').gsub('/', '\\')
        secedit('/configure', '/db', tmp_sdb_file, '/cfg', in_file_path(@resource[:name]))
    end

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
        out_file_path = File.join(Puppet[:vardir], 'rvsecurityoptionsoutput.txt').gsub('/', '\\')
        Puppet.debug out_file_path
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
          value = value || ''
        elsif res_mapping['reg_type'] == '4' then
        end

        new({
          :name      => res_displayname,
          :ensure    => :present,
          :sovalue   => value,
        })
      }

   end

end
