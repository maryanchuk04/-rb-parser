require_relative "./infrastructure/app_config_loader"
require_relative "./infrastructure/logger_manager"
require_relative './parsers/simple_website_parser'

require_relative "./models/item"
require_relative "./models/cart"

module RbParser
  class Main
    def self.start
      config_loader = AppConfigLoader.new("config/default_config.yaml", "config/yaml")
      config_loader.load_libs
      config_data = config_loader.config
      config_loader.pretty_print_config_data

      LoggerManager.initialize_logger(config_data)
      LoggerManager.log_processed_file("example_file")
      LoggerManager.log_error("Example error")

      # Here is example of usage Item model 🚀
      item = RbParser::Item.new(name: "Товар 1", price: 150) do |i|
        i.description = "Це опис товару 1"
        i.category = "Категорія 1"
      end

      puts item
      puts item.to_h
      puts item.inspect

      item.update do |i|
        i.name = "Новий товар"
        i.price = 100
      end

      puts item.info

      fake_item = RbParser::Item.generate_fake
      puts fake_item.info

      # #Example of usage cart

      cart = RbParser::Cart.new
      cart.generate_test_items(5)
      cart.show_all_items

      cart.save_to_file
      cart.save_to_json
      cart.save_to_csv
      cart.save_to_yml

      puts "Class info: #{Cart.class_info}"
      puts "Total items created: #{Cart.item_count}"

      # Usage od Enumerable methods
      expensive_items = cart.select_items { |item| item[:price] > 50 }
      puts "Expensive items: #{expensive_items}"

      puts "==================== Lab3.4 ========================"
      config_path = './config/yaml/web_parser.yaml'
      parser = SimpleWebsiteParser.new(config_path)
      parser.start_parse
      puts "===================================================="

    end
  end
end

RbParser::Main.start
