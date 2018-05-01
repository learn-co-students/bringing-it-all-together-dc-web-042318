require 'pry'

class Dog

    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end

    def save
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(hash)
        new_dog = self.new(name: hash[:name], breed: [hash[:breed]])
        new_dog.save
        new_dog
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        dog_data = DB[:conn].execute(sql, id)[0]
        dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        dog
    end

    def self.find_or_create_by(hash)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
        dog = DB[:conn].execute(sql, hash[:name], hash[:breed])
        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
            dog = self.create(name: hash[:name], breed: hash[:breed])
        end
        dog
    end

    def self.new_from_db(row)
        new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
        new_dog
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
        dog_data = DB[:conn].execute(sql, name)[0]
        dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        dog
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end