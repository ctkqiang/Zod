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
        begin
            case @arguements[0]
            when "-sip"
                # TODO ADJUST THIS
                name = @arguements[1]
                nationality = @arguements[2]
                arrestWarrantCountry = @arguements[3]
                sex = @arguements[4]

                Interpol.new(
                    "umar",
                    "MY",
                    "MY",
                    "M"
                ).search
            when "-sp"
                puts "l"
            end
        rescue => exception
            puts exception.message
        else
            puts "Invalid Command!"
        end
    end
end

Zod.new(ARGV).run