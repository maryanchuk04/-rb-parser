require_relative "./infrastructure/app_config_loader"
require_relative "./infrastructure/logger_manager"
require_relative "./parsers/simple_website_parser"
require_relative "./infrastructure/configurator"

require_relative "./models/item"
require_relative "./models/cart"
require_relative "./models/database_connector"

module RbParser
  class Main
    def self.start
      config_loader = AppConfigLoader.new("config/default_config.yaml", "config/yaml")
      config_loader.load_libs
      config_data = config_loader.config
      config_loader.pretty_print_config_data

      LoggerManager.initialize_logger(config_data)
      LoggerManager.log_processed_file("example_file")

      # # Here is example of usage Item model 🚀
      # item = RbParser::Item.new(name: "Item 1", price: 150) do |i|
      #   i.description = "Here is description 1"
      #   i.category = "Category 1"
      # end

      # puts item
      # puts item.to_h
      # puts item.inspect

      # item.update do |i|
      #   i.name = "New Item"
      #   i.price = 100
      # end

      # puts item.info

      # fake_item = RbParser::Item.generate_fake
      # puts fake_item.info

      # # #Example of usage cart
      # puts "\n\n===================== Lab3.2 ==========================\n\n"
      # cart = RbParser::Cart.new
      # cart.generate_test_items(5)
      # cart.show_all_items

      # cart.save_to_file
      # cart.save_to_json
      # cart.save_to_csv
      # cart.save_to_yml

      # puts "Class info: #{Cart.class_info}"
      # puts "Total items created: #{Cart.item_count}"

      # # Usage od Enumerable methods
      # expensive_items = cart.select_items { |item| item[:price] > 50 }
      # puts "Expensive items: #{expensive_items}"

      # # Configurator boom 😎
      # puts "\n\n===================== Lab3.3 ==========================\n\n"
      # configurator = RbParser::Configurator.new

      # puts "\n\nStarted configuration: #{configurator.config}\n"

      # configurator.configure(
      #   run_website_parser: 1,
      #   run_save_to_csv: 1,
      #   run_save_to_yaml: 1,
      #   run_save_to_sqlite: 1
      # )

      # puts "==================== Lab3.4 ========================"
      # config_path = "./config/yaml/web_parser.yaml"
      # parser = SimpleWebsiteParser.new(config_path)
      # parser.start_parse
      # puts "===================================================="
      # puts "\n\n=======================================================\n\n"

      # # Usage of connection to database
      # puts "==================== Lab3.5 ========================"
      # config_path = "/Users/vovaromanyuck/Desktop/rb-parser/config/default_config.yaml"

      # connector = DatabaseConnector.new(config_path)

      # connector.connect_to_databases

      # connector.close_connections

      parser_config_path = "config/yaml/web_parser.yaml"
      db_config_path = "config/yaml/database_config.yaml"

      engine = RbParser::Engine.new(parser_config_path, db_config_path)
      engine.run
    end
  end
end

RbParser::Main.start
