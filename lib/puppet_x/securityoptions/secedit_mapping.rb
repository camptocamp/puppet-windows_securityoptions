require 'json'

module PuppetX
  module Securityoptions
    class Mappingtables
      def mapping_table
        @@mapping_table ||= JSON.parse(File.read(mapping_table_file))
      end

      def mapping_table_file
        File.join(File.dirname(__FILE__), 'secedit_mapping.json')
      end

      def get_displayname(namevalue, category)
        mysearch = mapping_table[category].find { |p| p['name'].casecmp(namevalue.downcase).zero? }
        mysearch['displayname']
      end

      def get_name(namevalue, category)
        mysearch = mapping_table[category].find { |p| p['displayname'].casecmp(namevalue.downcase).zero? }
        mysearch['displayname']
      end

      def valid_name?(namevalue, category)
        mapping = mapping_table[category].find { |p| p['name'].casecmp(namevalue.downcase).zero? }
        if mapping
          return true
        else
          return false
        end
      end

      def valid_displayname?(namevalue, category)
        mapping = mapping_table[category].find { |p| p['displayname'].casecmp(namevalue.downcase).zero? }
        if mapping
          return true
        else
          return false
        end
      end

      def get_mapping(namevalue, category)
        mapping = mapping_table[category].find { |p| p['displayname'].casecmp(namevalue.downcase).zero? }
        mapping
      end
    end
  end
end
