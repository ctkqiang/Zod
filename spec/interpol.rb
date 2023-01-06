require "httparty"
require "json"
require_relative "../model/interpol.model.rb"

class Interpol 
    attr_accessor :name, :nationality, :warrantissuedcountry, :sex
    
    def initialize(name, nationality, warrantissuedcountry, sex)
        @name = name.swapcase
        @nationality = nationality.swapcase
        @warrantissuedcountry = warrantissuedcountry.swapcase 
        @sex = sex.swapcase
        @base = "https://ws-public.interpol.int/notices/v1/red?nationality=#{@nationality}"
    end

    def listAll
        response = HTTParty.get(@base)
        
        body = JSON.parse(response.body) if response.code == 200

        for count in 0..(body["_embedded"]["notices"].length) - 1 do
            puts InterpolResponse.new(
                body["_embedded"]["notices"][count]["forename"],
                body["_embedded"]["notices"][count]["date_of_birth"],
                body["_embedded"]["notices"][count]["entity_id"],
                body["_embedded"]["notices"][count]["nationalities"][0],
                body["_embedded"]["notices"][count]["name"],
                body["_embedded"]["notices"][count]["_links"]["images"]["href"],
                body["_embedded"]["notices"][count]["_links"]["self"]["href"]
            ).toMap
        end
    end

    def search
        response = HTTParty.get("#{@base}&ageMax=100&ageMin=18&sexId=#{@sex}&arrestWarrantCountryId=#{@warrantissuedcountry}&page=1&resultPerPage=200&name=#{@name}")
        
        body = JSON.parse(response.body) if response.code == 200

        for count in 1..(body["_embedded"]["notices"].length) do
            updatedCount = (count - 1)
            
            puts InterpolResponse.new(
                body["_embedded"]["notices"][updatedCount]["forename"],
                body["_embedded"]["notices"][updatedCount]["date_of_birth"],
                body["_embedded"]["notices"][updatedCount]["entity_id"],
                body["_embedded"]["notices"][updatedCount]["nationalities"][0],
                body["_embedded"]["notices"][updatedCount]["name"],
                body["_embedded"]["notices"][updatedCount]["_links"]["images"]["href"],
                body["_embedded"]["notices"][updatedCount]["_links"]["self"]["href"]
            ).toMap
        end
    end
end