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
      def valid_name?(namevalue, category)
        mappings = mapping_table
        mysearch = mappings[category].find { |p| p['DisplayName'].downcase == namevalue.downcase}
        if mysearch
          return true
        else
          return false
        end
      end
      def get_mapping(namevalue, category)
        mapping = mapping_table[category].find { |p| p['DisplayName'].downcase == namevalue.downcase}
        return mapping 
      end
    end
  end
end

