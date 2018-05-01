require 'pry'
class Dog
     attr_accessor :name, :breed, :id
   

     def initialize(name:nil, breed:nil, id:nil)
        @name = name
        @breed = breed
        @id = id
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
        sql = <<-SQL
            DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
     end

     def save
        if self.id
            self.update
        else
            sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
            DB[:conn].execute(sql, self.name, self.breed)
            sql = "SELECT last_insert_rowid() FROM dogs"
            @id = DB[:conn].execute(sql)[0][0]
        end
        self
     end

     def self.create(attributes)
        new_dog = self.new
        new_dog.name = attributes[:name]
        new_dog.breed = attributes[:breed]
        new_dog.save
        new_dog
     end

     def self.new_from_db(row)
        new_dog = self.new
        new_dog.name = row[1]
        new_dog.breed = row[2]
        new_dog.id = row[0]
        new_dog
     end

     def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        self.new_from_db(DB[:conn].execute(sql,id).first)
     end

     def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name = ? and breed = ?"
        dog_row = DB[:conn].execute(sql,name, breed).first
        if dog_row
        dog = self.new_from_db(dog_row)
        else
            hash = {name: name, breed: breed}
            self.create(hash)
        end
     end

     def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        self.new_from_db(DB[:conn].execute(sql,name).first)
     end

    def update 
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end