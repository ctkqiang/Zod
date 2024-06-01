require "optparse"
require "yaml"
require "socket"
require_relative "./spec/interpol.rb"
require_relative "./controller/downloader.rb"

class Zod
  attr_accessor :arguments, :options, :config

  def initialize(arguments)
    @arguments = arguments
    @options = {}
    @exception_counter = 0

    load_config
    parse_options
    run
  end

  def load_config
    config_file = "config.yml"

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

      opts.on("--http {Website Url}", "Scan Everything about the web") do |http_tools|
        @options[:http] = http_tools
      end
    end.parse!(@arguments)
  end

  def run
    case
    when @options[:version]
      display_version
    when @options[:sip]
      handle_sip_option
    when @options[:lai]
      handle_lai_option
    when @options[:http]
      http_tools 
    else
      puts "Invalid Command! Use --help for more information."
    end
  rescue StandardError => e
    puts "An error occurred: #{e.message}"
  ensure
    if @exception_counter > 0
      puts "Encountered #{@exception_counter} error(s). Check logs for details."
    end
  end

  private

  def display_version
    version = File.exist?("./version") ? File.read("./version") : "Unknown Version"
    puts "Project Zod Version: #{version}"
  end
  
  def handle_sip_option
    if validate_sip_options(@options[:sip])
      name, nationality, arrest_warrant_country, sex = @options[:sip]
      Interpol.new(name, nationality, arrest_warrant_country, sex).search
    end
  end

  def validate_sip_options(options)
    options.each do |option|
      if option.nil? || option.strip.empty?
        @exception_counter += 1
        puts "The name, nationality, arrest warrant country, and sex must not be empty!"
        return false
      end
    end
    true
  end

  def website_to_ip(url)
    IPSocket.getaddress(url).sub(/^https?:\/\//, "")
  end

  def http_tools
    is_whatweb_existed = run_command("which whatweb > /dev/null 2>&1").strip
    is_nmap_existed = run_command("which nmap").strip

    web_addr = ARGV[0]
    ip_addr = website_to_ip(web_addr)

    if get_os == "mac" 
      if is_nmap_existed.empty?
        begin
          run_command("brew install nmap --verbose")
        rescue StandardError => exception
          puts "HTTP_TOOLS::#{exception.message}"
        end
      end
    else
      if is_nmap_existed.empty?
        nmap = Downloader.new("repo/", "https://github.com/nmap/nmap.git")
        nmap.git_clone
      end
    end

    run_command("sudo nmap --script vuln #{ip_addr}")
  end

  def handle_lai_option
    country = @options[:lai]
    if country.nil? || country.strip.empty?
      puts "The nationality is required!"
    else
      Interpol.new("", country, "", "").list_all
    end
  end

  def run_command(command)
    output = `#{command}`
    output
  end

  def get_os
    host_os = RbConfig::CONFIG["host_os"]

    case host_os
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      "win"
    when /darwin|mac os/
      "mac"
    when /linux/
      "linux"
    when /solaris|bsd/
      "bsd"
    else
      "error"
    end
  end
end

Zod.new(ARGV)
