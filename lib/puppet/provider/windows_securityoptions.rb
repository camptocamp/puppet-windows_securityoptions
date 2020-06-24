require 'puppet/util/windows'

begin
  require File.expand_path('../../util/ini_file', __FILE__)
rescue LoadError
  # in case we're not in libdir
  require File.expand_path('../../../../spec/fixtures/modules/inifile/lib/puppet/util/ini_file', __FILE__)
end

class Puppet::Provider::Windows_SecurityOptions < Puppet::Provider
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

  def flush
    tmp_sdb_file = File.join(Puppet[:vardir], 'secedit.sdb').tr('/', '\\')
    secedit('/configure', '/db', tmp_sdb_file, '/cfg', in_file_path)
  end

  def self.prefetch(resources)
    instances.each do |right|
      resources.select { |_title, res|
        res[:name].casecmp(right.get(:name).downcase).zero?
      }.map do |_name, res|
        res.provider = right
      end
    end
  end

  def self.get_secedit_exports
    out_file_path = File.join(Puppet[:vardir], 'secedit_exports.txt').tr('/', '\\')
    # Once the file exists in UTF-8, secedit will also use UTF-8
    File.open(out_file_path, 'w') { |f| f.write('# We want UTF-8') }
    secedit('/export', '/cfg', out_file_path)
    Puppet::Util::IniFile.new(out_file_path, '=')
  end

  def self.secedit_exports
    puts 'in secedit_exports'
    @exports ||= get_secedit_exports
  end

  def self.attr_so_reader(name)
    define_method(name) do
      @property_hash[name.to_sym]
    end
  end

  def self.attr_so_writer(name)
    define_method("#{name}=") do |value|
      write_export(@resource[:name], value)
      @property_hash[name.to_sym] = value
    end
  end

  def self.attr_so_accessor(name)
    attr_so_reader(name)
    attr_so_writer(name)
  end

  def in_file_path
    option = @resource[:name].scan(%r{[\da-z]}i).join
    File.join(Puppet[:vardir], write_export_filename, "#{option}.txt").tr('/', '\\')
  end

  def map_option(option)
    option
  end

  def map_value(_option, value)
    [value]
  end

  def write_export_filename
    raise 'write_export_filename needs to be implemented'
  end

  def section_name
    raise 'section_name needs to be implemented'
  end

  def write_export(option, value)
    dir = File.join(Puppet[:vardir], write_export_filename)
    Dir.mkdir(dir) unless Dir.exist?(dir)

    File.open(in_file_path, 'w') do |f|
      f.write <<-EOF
[Unicode]
Unicode=yes
[#{section_name}]
#{map_option(option)} = #{map_value(option, value).join(',')}
[Version]
signature="$CHICAGO$"
Revision=1
      EOF
    end
  end
end
