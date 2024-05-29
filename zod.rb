require 'optparse'
require 'logger'
require 'yaml'
require_relative './spec/interpol.rb'

class Zod
  attr_accessor :arguments, :options, :logger, :config

  def initialize(arguments)
    @arguments = arguments
    @options = {}
    @exception_counter = 0
    setup_logger
    load_config
    parse_options
  end

  def setup_logger
    log_file = @config['log_file'] || 'zod.log'
    @logger = Logger.new(log_file, 'weekly')
    @logger.level = Logger::DEBUG
    @logger.datetime_format = '%Y-%m-%d %H:%M:%S'
  end

  def load_config
    config_file = 'config.yml'
    if File.exist?(config_file)
      @config = YAML.load_file(config_file)
    else
      @config = {}
    end
  rescue StandardError => e
    puts "Failed to load configuration: #{e.message}"
    @config = {}
  end

  def parse_options
    OptionParser.new do |opts|
      opts.banner = "Usage: ruby zod.rb [options]"
      opts.separator ""
      opts.separator "Options:"

      opts.on("--help", "Show this message") do
        puts opts
        exit
      end

      opts.on("--version", "Show version") do
        @options[:version] = true
      end

      opts.on("--sip NAME,NATIONALITY,ARREST_WARRANT_COUNTRY,SEX", Array, "List specific user") do |list|
        @options[:sip] = list
      end

      opts.on("--lai COUNTRY", "List all wanted criminals by nationality") do |country|
        @options[:lai] = country
      end

      opts.on("--sp", "Sample option for demonstration") do
        @options[:sp] = true
      end
    end.parse!(@arguments)
  end

  def validate_sip_options(options)
    options.each do |option|
      if option.nil? || option.strip.empty?
        @exception_counter += 1
        @logger.error("The {name}, {nationality}, {arrestWarrantCountry} and {sex} must not be empty!")
        return false
      end
    end
    true
  end

  def run
    case
    when @options[:version]
      display_version
    when @options[:sip]
      handle_sip_option
    when @options[:lai]
      handle_lai_option
    when @options[:sp]
      @logger.info("Sample option triggered")
    else
      @logger.error("Invalid Command!")
      puts "Invalid Command! Use --help for more information."
    end
  rescue StandardError => e
    @logger.error("An error occurred: #{e.message}")
    @logger.debug(e.backtrace.join("\n"))
  ensure
    if @exception_counter > 0
      puts "Encountered #{@exception_counter} error(s). Check logs for details."
    end
  end

  private

  def display_version
    version = File.exist?('./version') ? File.read('./version') : 'Unknown Version'
    puts "Project Zod Version: #{version}"
  end

  def handle_sip_option
    if validate_sip_options(@options[:sip])
      name, nationality, arrest_warrant_country, sex = @options[:sip]
      Interpol.new(name, nationality, arrest_warrant_country, sex).search
    end
  end

  def handle_lai_option
    country = @options[:lai]
    if country.nil? || country.strip.empty?
      @logger.error("The Nationality is required!")
    else
      Interpol.new("", country, "", "").list_all
    end
  end
end

Zod.new(ARGV).run
