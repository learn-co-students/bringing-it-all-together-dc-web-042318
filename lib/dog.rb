require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(name: nil, breed: nil, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql =  <<-SQL
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
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
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

  def self.find_by_id(number)
     sql = <<-SQL
       SELECT *
       FROM dogs
       WHERE id = ?
     SQL

    self.new_from_db(DB[:conn].execute(sql, number).first)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    self.new_from_db(DB[:conn].execute(sql, name).first)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL
     dog_row = DB[:conn].execute(sql, name, breed).first
     if dog_row
       dog = self.new_from_db(dog_row)
     else
       dog = self.create(name: name, breed: breed)
     end
   end

  def update
     sql = <<-SQL
       UPDATE dogs
       SET name = ?
       WHERE id = ?
     SQL

     DB[:conn].execute(sql, self.name, self.id)
   end
end
