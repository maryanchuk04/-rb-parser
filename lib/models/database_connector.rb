require "sqlite3"
require "mongo"
require "yaml"
require "erb"

class DatabaseConnector
  attr_reader :sqlite_db, :mongodb_client

  def initialize(config_path)
    config_content = File.read(config_path)
    parsed_content = ERB.new(config_content).result
    @config = YAML.safe_load(parsed_content)

    @sqlite_db = nil
    @mongodb_client = nil
  end

  def connect_to_databases
    if @config["database"]["type"] == "sqlite" || @config["database"]["type"] == "both"
      connect_to_sqlite
    end
    return unless @config["database"]["type"] == "mongodb" || @config["database"]["type"] == "both"

    connect_to_mongodb
  end

  def close_connections
    close_sqlite_connection
    close_mongodb_connection
  end

  private

  def connect_to_sqlite
    db_path = @config["database"]["path"]
    @sqlite_db = SQLite3::Database.new(db_path)
    puts "Connected to SQLite database at #{db_path}"
  rescue SQLite3::Exception => e
    puts "Failed to connect to SQLite database: #{e.message}"
  end

  def connect_to_mongodb
    uri = @config["database"]["uri"]
    database_name = @config["database"]["name"]
    @mongodb_client = Mongo::Client.new(uri, database: database_name)
    puts "Connected to MongoDB database '#{database_name}' at #{uri}"
  rescue Mongo::Error => e
    puts "Failed to connect to MongoDB database: #{e.message}"
  end

  def close_sqlite_connection
    return unless @sqlite_db

    @sqlite_db.close if @sqlite_db.is_a?(SQLite3::Database)
    @sqlite_db = nil
    puts "Closed SQLite database connection."
  end

  def close_mongodb_connection
    return unless @mongodb_client

    @mongodb_client.close if @mongodb_client.is_a?(Mongo::Client)
    @mongodb_client = nil
    puts "Closed MongoDB database connection."
  end
end
