require "optparse"
require_relative "./spec/interpol.rb"

=begin
@@author John Melody Me<johnmelodyme@icloud.com>
MIT License
Copyright (c) 2023 John Melody Me
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
=end

class Zod 
    attr_accessor :arguements

    def initialize(arguements)
        @arguements = arguements
        @options = {}
    end

    def run()
        OptionParser.new do |parser|
            parser.on("-spn", "--search-phone-number", "Search phone number") do
                # TODO add 
                puts "s"
            end

            parser.on("-sip", "-search-interpol", "Search given details in database") do 
                # TODO ADJUST THIS
                Interpol.new(
                    "umar",
                    "MY",
                    "MY",
                    "M"
                ).search
            end 
        end.parse!
    end
end

Zod.new(ARGV).run