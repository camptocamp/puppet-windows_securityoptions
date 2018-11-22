require 'puppet/util/windows'

begin
  require File.expand_path('../../../util/ini_file', __FILE__)
rescue LoadError
  # in case we're not in libdir
  require File.expand_path('../../../../../spec/fixtures/modules/inifile/lib/puppet/util/ini_file', __FILE__)
end

Puppet::Type.type(:so_privilegerights).provide(:so_privilegerights) do
    defaultfor :osfamily => :windows
    confine :osfamily => :windows

    commands :secedit => 'secedit.exe'

    def exists?
        @property_hash[:ensure] == :present
    end

    def create
        write_export(@resource[:name], @resource[:sid])
        @property_hash[:ensure] = :present
    end

    def destroy
        write_export(@resource[:name], [])
        @property_hash[:ensure] = :absent
    end

    def sid
        @property_hash[:sid]
    end

    def sid=(value)
        write_export(@resource[:name], value)
        @property_hash[:sid] = value
    end

    def in_file_path(right)
        File.join(Puppet[:vardir], 'secedit_export', "#{right}.txt").gsub('/', '\\')
    end

    def write_export(right, value)
        dir = File.join(Puppet[:vardir], 'secedit_export')
        Dir.mkdir(dir) unless Dir.exist?(dir)

        sid = name_to_sid(value)

        File.open(in_file_path(right), 'w') do |f|
          f.write <<-EOF
[Unicode]
Unicode=yes
[Privilege Rights]
#{right} = #{sid.join(',')}
[Version]
signature="$CHICAGO$"
Revision=1
          EOF
        end
    end

    def flush
        secedit('/configure', '/db', 'secedit.sdb', '/cfg', in_file_path(@resource[:name]))
    end

    def name_to_sid(users)
        users.map { |user| '*' + Puppet::Util::Windows::SID.name_to_sid(user) }
    end

    def sid_in_sync?(current, should)
        return false unless current
        current_sids = current
        specified_sids = name_to_sid(should)
        (specified_sids & current_sids) == specified_sids
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
        out_file_path = File.join(Puppet[:vardir], 'secedit_import.txt').gsub('/', '\\')
        # Once the file exists in UTF-8, secedit will also use UTF-8
        File.open(out_file_path, 'w') { |f| f.write('# We want UTF-8') }
        secedit('/export', '/cfg', out_file_path, '/areas', 'user_rights')
        ini = Puppet::Util::IniFile.new(out_file_path, '=')
        ini.get_settings('Privilege Rights').map { |k, v|
            new({
                :name   => k,
                :ensure => :present,
                :sid    => v.split(','),
            })
        }
    end
end
