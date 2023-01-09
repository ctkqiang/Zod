require "terminal-table"

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

    def toTable
        rows = []
        rows << [:name, @name.to_s]
        rows << [:forename, @forename.to_s]
        rows << [:date_of_birth, @date_of_birth.to_s]
        rows << [:entity_id, @entity_id.to_s]
        rows << [:image, @image.to_s]
        rows << [:link, @link.to_s]
        rows << [:nationalities, @nationalities.to_s]

        table = Terminal::Table.new :rows => rows
    end
end