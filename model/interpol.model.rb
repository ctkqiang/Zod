class InterpolResponse 
    attr_accessor :forename, :date_of_birth, :entity_id, :nationalities, :name, :image, :link

    def initialize(forename, date_of_birth, entity_id, nationalities, name, image, link)
        @forename = forename 
        @date_of_birth = date_of_birth
        @entity_id = entity_id
        @nationalities = nationalities
        @name = name
        @image = image
        @link = link
    end

    def toMap
        JSON.pretty_generate({ 
            :name => @name.to_s,
            :forename => @forename.to_s,
            :date_of_birth => @date_of_birth.to_s,
            :entity_id => @entity_id.to_s,
            :image => @image.to_s,
            :link => @link.to_s,
            :nationalities => @nationalities.to_s
        })
    end 
end