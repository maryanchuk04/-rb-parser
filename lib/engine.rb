require "csv"
require "json"
require "yaml"
require "zip"
require "pony"

require_relative "./parsers/simple_website_parser"
require_relative "./models/item"

module RbParser
  class Engine
    attr_reader :parser

    def initialize(config_path, db_config_path)
      @config_path = config_path
      @db_connector = DatabaseConnector.new(db_config_path)
      load_config
      initialize_parser
    end

    def load_config
      @config = YAML.load_file(@config_path)
      puts "Configuration loaded successfully from #{@config_path}"
    rescue StandardError => e
      puts "Failed to load configuration: #{e.message}"
    end

    def initialize_parser
      @parser = RbParser::SimpleWebsiteParser.new(@config_path)
    end

    def run
      parser.start_parse
      puts "Items collected: #{parser.item_collection.size}"

      parser.item_collection.each_with_index do |item, index|
        puts "Item #{index + 1}: #{item.to_h}"
      end

      if parser.item_collection.empty?
        puts "No items were collected. Check the configuration and selectors."
        return
      end

      run_save_to_csv
      run_save_to_json
      run_save_to_yaml
      puts "Data saved to CSV, JSON, and YAML formats."
    end

    def run_save_to_csv
      CSV.open("output/data.csv", "w") do |csv|
        csv << ["Name", "Price", "Description", "Category", "Image Path"]
        parser.item_collection.each do |item|
          csv << [item.name, item.price, item.description, item.category, item.image_path]
        end
      end
      puts "Data saved to CSV at output/data.csv"
    end

    def run_save_to_json
      data = parser.item_collection.map(&:to_h)
      File.write("output/data.json", JSON.pretty_generate(data))
      puts "Data saved to JSON at output/data.json"
    end

    def run_save_to_yaml
      data = parser.item_collection.map(&:to_h)
      File.write("output/data.yaml", data.to_yaml)
      puts "Data saved to YAML at output/data.yaml"
    end
  end
end
