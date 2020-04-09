require 'puppet/util/windows'

require File.join(File.dirname(__FILE__), '../../../puppet/provider/windows_securityoptions')

Puppet::Type.type(:so_privilegerights).provide(:so_privilegerights, parent: Puppet::Provider::Windows_SecurityOptions) do
  defaultfor :osfamily => :windows
  confine :osfamily => :windows

  commands :secedit => 'secedit.exe'

    attr_so_accessor(:sid)


    def write_export_filename
      'secedit_export'
    end

    def section_name
      'Privilege Rights'
    end

    def map_value(value)
      name_to_sid(value)
    end

    def name_to_sid(users)
        users.map { |user| '*' + Puppet::Util::Windows::SID.name_to_sid(user) }
    end

    def sid_in_sync?(current, should)
        return false unless current
        current_sids = current
        specified_sids = name_to_sid(should)
        (specified_sids & current_sids) == (specified_sids | current_sids)

        #(specified_sids & current_sids) == specified_sids
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
