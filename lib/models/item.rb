require 'faker'
require_relative 'logger_manager'

module RbParser
  class Item
    include Comparable

    attr_accessor :name, :price, :description, :category, :image_path

    def initialize(params = {})
      @name = params[:name] || "Unknown"
      @price = params[:price] || 0.0
      @description = params[:description] || "No description"
      @category = params[:category] || "Uncategorized"
      @image_path = params[:image_path] || "default.jpg"

      LoggerManager.log_processed_file("Item initialized: #{self}")

      yield(self) if block_given?
    end

    def <=>(other)
      price <=> other.price
    end

    def to_s
      "#{self.class.name} - #{instance_variables.map { |attr| "#{attr.to_s.delete('@')}: #{instance_variable_get(attr)}" }.join(', ')}"
    end

    def to_h
      instance_variables.each_with_object({}) do |attr, hash|
        hash[attr.to_s.delete('@').to_sym] = instance_variable_get(attr)
      end
    end

    def inspect
      "<#{self.class}: #{to_h}>"
    end

    alias_method :info, :to_s

    def update
      yield(self) if block_given?
    end

    def self.generate_fake
      new(
        name: Faker::Commerce.product_name,
        price: Faker::Commerce.price,
        description: Faker::Lorem.sentence,
        category: Faker::Commerce.department,
        image_path: "#{Faker::Lorem.word}.jpg"
      )
    end
  end
end
