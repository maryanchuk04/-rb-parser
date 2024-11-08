require_relative "./infrastructure/app_config_loader"
require_relative "./infrastructure/logger_manager"
require_relative "./infrastructure/configurator"
require_relative "./models/item"

module RbParser
  class Main
    def self.start
      config_loader = AppConfigLoader.new("config/default_config.yaml", "config/yaml")

      config_loader.load_libs

      config_data = config_loader.config

      config_loader.pretty_print_config_data

      LoggerManager.initialize_logger(config_data)
      LoggerManager.log_processed_file("example_file")

      # Here is example of usage Item model 🚀
      item = RbParser::Item.new(name: "Item 1", price: 150) do |i|
        i.description = "Here is description 1"
        i.category = "Category 1"
      end

      puts item.to_s
      puts item.to_h
      puts item.inspect

      item.update do |i|
        i.name = "New Item"
        i.price = 100
      end

      puts item.info

      fake_item = RbParser::Item.generate_fake
      puts fake_item.info


      # Configurator boom 😎
      puts "\n\n===================== Lab3.3 ==========================\n\n"
      configurator = RbParser::Configurator.new

      puts "\n\nStarted configuration: #{configurator.config}\n"

      configurator.configure(
        run_website_parser: 1,
        run_save_to_csv: 1,
        run_save_to_yaml: 1,
        run_save_to_sqlite: 1
      )

      puts "Configs after updates: #{configurator.config}\n\n"
      puts "Available configs: #{RbParser::Configurator.available_methods}"
      puts "\n\n=======================================================\n\n"
    end
  end
end

RbParser::Main.start
