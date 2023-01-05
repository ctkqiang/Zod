require "httparty"

class Interpol 
    attr_accessor :name, :nationality, :warrantissuedcountry, :sex
    
    def initialize(name, nationality, warrantissuedcountry, sex)
        @name = name
        @nationality = nationality
        @warrantissuedcountry = warrantissuedcountry
        @sex = sex
    end

    def search()
        response = HTTParty.get(
            "https://ws-public.interpol.int/notices/v1/red?nationality=#{@nationality}&ageMax=100&ageMin=18&sexId=#{@sex}&arrestWarrantCountryId=#{@warrantissuedcountry}&page=1&resultPerPage=200&&name=#{@name}"
        )

        puts response.body if response.code == 200
    end
end