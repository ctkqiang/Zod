require "uri"
require "git"
require "httparty"

class Downloader
    attr_accessor :path, :url

    def initialize(path, url)
        puts "Downloader Initializing..."
        
        @url = url
        @path = path
    end

    def git_clone
        begin
            Git.clone(@url, @path)
        rescue StandardError => e
            puts "Git clone failed: #{e.message}"
        else
            puts "Git clone succeeded | saved to #{@path}"
        end
    end 

    def file
        begin
            response = HTTParty.get(@url)

            if response.success?
                File.open(@path, "wb") do |file|
                    file.write(response.body)
                end

                puts "File downloaded successfully to #{destination}"
            else
                puts "Failed to download file: #{response.message}"
            end

        rescue StandardError => exception
            puts "An error occurred during file download: #{exception.message}"
        end
    end
end