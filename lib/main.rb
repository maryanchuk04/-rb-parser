require_relative "./infrastructure/app_config_loader"
require_relative "./infrastructure/logger_manager"
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
      LoggerManager.log_error("Example error")

      # Here is example of usage Item model 🚀
      item = RbParser::Item.new(name: "Товар 1", price: 150) do |i|
        i.description = "Це опис товару 1"
        i.category = "Категорія 1"
      end

      puts item.to_s
      puts item.to_h
      puts item.inspect

      item.update do |i|
        i.name = "Новий товар"
        i.price = 100
      end

      puts item.info

      fake_item = RbParser::Item.generate_fake
      puts fake_item.info
    end
  end
end

RbParser::Main.start
