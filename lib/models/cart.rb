require "json"
require "csv"
require "yaml"
require_relative "./item_container"
require_relative "../infrastructure/logger_manager"

module RbParser
  class Cart
    include ItemContainer
    include Enumerable

    attr_accessor :items

    def initialize
      @items = []
      LoggerManager.log_info("Cart initialized with an empty items array")
    end

    def save_to_file(filename = "items.txt")
      File.open(filename, "w") do |file|
        @items.each { |item| file.puts item.to_s }
      end
      LoggerManager.log_info("Items saved to text file: #{filename}")
    end

    def generate_test_items(count)
      count.times do |i|
        item = { name: "Item #{i + 1}", price: rand(10..100), quantity: rand(1..5) }
        add_item(item)
      end
      LoggerManager.log_info("#{count} test items generated")
    end

    def save_to_json(filename = "items.json")
      File.write(filename, @items.to_json)
      LoggerManager.log_info("Items saved to JSON file: #{filename}")
    end

    def save_to_csv(filename = "items.csv")
      CSV.open(filename, "w") do |csv|
        csv << @items.first.keys if @items.any?
        @items.each { |item| csv << item.values }
      end
      LoggerManager.log_info("Items saved to CSV file: #{filename}")
    end

    def save_to_yml(dir = "items_yaml")
      Dir.mkdir(dir) unless Dir.exist?(dir)
      @items.each_with_index do |item, index|
        File.write("#{dir}/item_#{index + 1}.yml", item.to_yaml)
      end
      LoggerManager.log_info("Items saved to YAML files in directory: #{dir}")
    end

    def map_items(&block)
      items.map(&block)
    end

    def select_items(&block)
      items.select(&block)
    end

    def reject_items(&block)
      items.reject(&block)
    end

    def find_item(&block)
      items.find(&block)
    end

    def reduce_items(initial_value, &block)
      items.reduce(initial_value, &block)
    end

    def all_items?(&block)
      items.all?(&block)
    end

    def any_item?(&block)
      items.any?(&block)
    end

    def none_items?(&block)
      items.none?(&block)
    end

    def count_items(&block)
      items.count(&block)
    end

    def sort_items(&block)
      items.sort(&block)
    end

    def uniq_items
      items.uniq
    end

    def each(&block)
      @items.each(&block)
    end
  end
end
