require 'mechanize'
require 'yaml'
require 'fileutils'
require 'securerandom'

require_relative '../infrastructure/logger_manager'
require_relative '../models/item'

module RbParser
  class SimpleWebsiteParser
    attr_reader :config, :agent, :item_collection

    def initialize(config_path)
      @config = YAML.load_file(config_path)
      @agent = Mechanize.new
      @item_collection = []
      LoggerManager.log_processed_file("Initialized SimpleWebsiteParser with config #{config_path}")
    end

    def start_parse
      LoggerManager.log_processed_file("Starting parsing process")
      url = config['start_page']

      if check_url_response(url)
        page = agent.get(url)
        product_links = extract_products_links(page)

        threads = product_links.map do |product_link|
          Thread.new do
            parse_product_page(product_link)
          end
        end

        threads.each(&:join)
        LoggerManager.log_processed_file("Finished parsing up to #{@max_products} product pages")
      else
        LoggerManager.log_error("Start URL is not accessible: #{url}")
      end
    end

    def extract_products_links(page)
      product_selector = config['selectors']['product_link_selector']
      links = page.search(product_selector).map { |link| link['href'] }
      LoggerManager.log_processed_file("Extracted #{links.size} product links")
      links
    end

    def parse_product_page(product_link)
      if check_url_response(product_link)
        product_page = agent.get(product_link)
        name = extract_product_name(product_page)
        price = extract_product_price(product_page)
        description = extract_product_description(product_page)
        image_url = extract_product_image(product_page)
        category = config['selectors']['category']

        image_path = save_product_image(image_url, category)

        item = Item.new(
          name: name,
          price: price,
          description: description,
          category: category,
          image_path: image_path
        )
        
        @item_collection << item
        LoggerManager.log_processed_file("Parsed product: #{name}, Price: #{price}, Description: #{description}, Category: #{category}, Image Path: #{image_path}")
      else
        LoggerManager.log_error("Product page is not accessible: #{product_link}")
      end
    end

    def extract_product_name(product)
      product.search(config['selectors']['name_selector']).text.strip
    end

    def extract_product_price(product)
      product.search(config['selectors']['price_selector']).text.strip
    end

    def extract_product_description(product)
      product.search(config['selectors']['description_selector']).text.strip
    end

    def extract_product_image(product)
      image = product.search(config['selectors']['image_selector']).first['src']
      LoggerManager.log_processed_file("Extracted image URL: #{image}")
      image
    end

    def save_product_image(image_url, category)
      media_dir = File.join('media_dir', category)
      FileUtils.mkdir_p(media_dir)
      image_path = File.join(media_dir, "#{SecureRandom.uuid}.jpg")

      begin
        @agent.get(image_url).save(image_path)
        LoggerManager.log_processed_file("Saved image to #{image_path}")
      rescue StandardError => e
        LoggerManager.log_error("Failed to download image: #{e.message}. Using default image.")
        image_path = File.join('media', 'default.jpg')
      end

      image_path
    end

    def check_url_response(url)
      begin
        response = agent.head(url)
        response.code.to_i == 200
      rescue StandardError => e
        LoggerManager.log_error("URL check failed for #{url}: #{e.message}")
        false
      end
    end
  end
end
