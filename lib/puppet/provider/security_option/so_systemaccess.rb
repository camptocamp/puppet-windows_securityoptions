require 'puppet/util/windows'
require 'pathname'


begin
  require File.expand_path('../../../util/ini_file', __FILE__)
rescue LoadError
  # in case we're not in libdir
  require File.expand_path('../../../../../spec/fixtures/modules/inifile/lib/puppet/util/ini_file', __FILE__)
end

Puppet::Type.type(:so_systemaccess).provide(:so_systemaccess) do
    require Pathname.new(__FILE__).dirname + '../../puppet_x/security_options/mappingtables'
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
        File.join(Puppet[:vardir], 'secedit_export', "#{securityoption}.txt").gsub('/', '\\')
    end

    def write_export(securityoption, value)
        dir = File.join(Puppet[:vardir], 'secedit_export')
        Dir.mkdir(dir) unless Dir.exist?(dir)

        File.open(in_file_path(securityoption), 'w') do |f|
          f.write <<-EOF
[Unicode]
Unicode=yes
[System Access]
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
        settings = []
        inst1 = []
        systemaccess_hash=[]
        out_file_path = File.join(Puppet[:vardir], 'so_systemaccess.txt').gsub('/', '\\')
        # Once the file exists in UTF-8, secedit will also use UTF-8
        File.open(out_file_path, 'w') { |f| f.write('# We want UTF-8') }
        secedit('/export', '/cfg', out_file_path, '/areas', 'securitypolicy')
        #inst1=getregistryvalues(out_file_path)
        #puts inst1.class
        #inst2=getsystemaccess(out_file_path)
        #puts inst2.class
        #puts inst2
        return getsystemaccess(out_file_path)
    end

   def self.getsystemaccess(out_file_path)
        ini = Puppet::Util::IniFile.new(out_file_path, '=')
        ini.get_settings('System Access').map { |k, v|
            #policy_hash = {
            
            new({
                :name      => k,
                :ensure    => :present,
                :sovalue   => v,
            })
            #inst = new(policy_hash)
            #systemaccess_hash << inst
            #systemaccess_hash << inst
        }

   end

end
