require 'optparse'
require 'yaml'
require 'socket'
require 'thread'
require 'resolv'
require 'terminal-table'
require 'uri'

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
      opts.banner = <<~HEREDOC
        _______________________________________________________
       /                                                       \\
      |    ________________________________________________     |
      |   |                                                |    |
      |   |  Welcome to Zod                                |    |
      |   |  Developed by ctkqiang                         |    |
      |   |________________________________________________|    |
      |_________________________________________________________|
      \_______________________________________________________/
             \\_______________________________________/
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      Usage => ruby zod.rb [options][arguments]

      HEREDOC
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

      opts.on("--http URL", "Scan Everything about the web") do |http_tools|
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
      http_tools(@options[:http])
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
    uri = URI.parse(url)
    host = uri.host || url
    Resolv.getaddress(host)
  rescue Resolv::ResolvError => e
    puts "Error: Could not resolve URL '#{url}'."
    puts "Error details: #{e.message}"
    nil
  end

  def scan_all_ports(ip, num_threads=10)
    ports = [0x15, 0x16, 0x17, 0x19, 0x1b, 0x19, 0x35, 0x6e, 0x8f, 0xcea, 0xd3d, 0x1f90, 0x1f40, 0xbb8, 0x210b, 0x170c]
    
    open_ports = []
    closed_ports = []
    mutex = Mutex.new
    timeout = 0x1

    puts "=> Scanning specific ports for #{ip} with #{num_threads} threads..."

    threads = []
    ports_queue = Queue.new
    ports.each { |port| ports_queue << port }

    num_threads.times do
      threads << Thread.new do
        while !ports_queue.empty?
          port = nil
          mutex.synchronize do
            port = ports_queue.pop if !ports_queue.empty?
          end

          next if port.nil?

          begin
            Timeout.timeout(timeout) do
              socket = Socket.new(:INET, :STREAM)
              remote_addr = Socket.sockaddr_in(port, ip)

              puts "=> Checking port #{port}..."

              socket.connect(remote_addr)
              mutex.synchronize { open_ports << port }
              
              puts "=> Port #{port} is open."
              socket.close
            end
          rescue Timeout::Error
            mutex.synchronize { closed_ports << port }
            puts "=> Port #{port} is closed (timeout)."
          rescue Errno::ECONNREFUSED
            mutex.synchronize { closed_ports << port }
            puts "=> Port #{port} is closed (connection refused)."
          rescue Errno::EHOSTUNREACH
            mutex.synchronize { closed_ports << port }
            puts "=> Port #{port} is closed (host unreachable)."
          rescue Errno::ENETUNREACH
            mutex.synchronize { closed_ports << port }
            puts "=> Port #{port} is closed (network unreachable)."
          rescue => e
            puts "Error on port #{port}: #{e.message}"
          end
        end
      end
    end

    threads.each(&:join)

    display_results(open_ports, closed_ports)

    { open_ports: open_ports, closed_ports: closed_ports }
  end

  def display_results(open_ports, closed_ports)
    table = Terminal::Table.new do |t|
      t.title = "Port Scan Results"
      t.headings = ["Port", "Status"]

      open_ports.each do |port|
        t.add_row([port, "Open"])
      end

      closed_ports.each do |port|
        t.add_row([port, "Closed"])
      end
    end

    puts table
  end

  def http_tools(web_addr)
    ip_addr = website_to_ip(web_addr)
    return unless ip_addr

    scan_all_ports(ip_addr)

    is_nmap_existed = run_command("which nmap").strip

    if get_os == "mac"
      if is_nmap_existed.empty?
        begin
          run_command("brew install nmap --verbose")
        rescue StandardError => exception
          puts "HTTP_TOOLS::#{exception.message}"
        end
      end
    elsif get_os == "linux"
      run_command("apt install nmap")
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

  def analyse_mobile_app
    is_mob_analysis_existed = Dir.exist?("repo/MobileAppAnalyzer")
    mobile_app_analyzer_repo = "https://github.com/ctkqiang/MobileAppAnalyzer.git"

    if is_mob_analysis_existed
      puts "Cloning MobileAppAnalyzer..."

      mobile_app_analyzer = Downloader.new("repo/", "https://github.com/ctkqiang/MobileAppAnalyzer.git")
      mobile_app_analyzer.git_clone
    else
      puts "Drop the path to your .apk/.ipa"

      phone_bin = ARGV[0]

      run_command("cd repo/MobileAppAnalyzer && ruby analyse.rb #{phone_bin} .")
    end
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
