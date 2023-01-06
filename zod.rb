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
        @exceptionCounter = 0
    end

    def run()
        begin
            case @arguements[0]
            when "-sip"
                name = @arguements[1]
                nationality = @arguements[2]
                arrestWarrantCountry = @arguements[3]
                sex = @arguements[4]

                if name.nil?|| nationality.nil?|| arrestWarrantCountry.nil?|| sex.empty?
                    @exceptionCounter += 1
                    puts "The {name}, {nationality}, {arrestWarrantCountry} and {sex} must not be empty!"
                else
                    Interpol.new(name, nationality, arrestWarrantCountry, sex).search
                end

            when "-lai"
                country = @arguements[1]

                if country.nil?
                    puts "The Nationality is required!"
                else  
                    Interpol.new("", country, "", "").listAll
                end

            when "-sp"
                puts "l"
            end
            
        rescue => exception
            puts exception.message
        else
            if @exceptionCounter < 0
                puts "Invalid Command!"
            end
        end
    end
end

Zod.new(ARGV).run