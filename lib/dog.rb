class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
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
        );
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
    if self.id.nil?
      sql = 'INSERT INTO dogs (name, breed) VALUES (?, ?);'
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
      self
    else
      self.update
    end
  end

  def self.create(data)
    dog = Dog.new(data)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?;
    SQL
    DB[:conn].execute(sql, id).map { |d| self.new_from_db(d) }.first
  end

  def self.find_or_create_by(data)
    dog = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ?', data[:name], data[:breed])[0]
    if dog
      self.new_from_db(dog)
    else
      self.create(data)
    end
  end

  def self.new_from_db(row)
    data = { id: row[0], name: row[1], breed: row[2] }
    Dog.new(data)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?;
    SQL
    DB[:conn].execute(sql, name).map { |d| self.new_from_db(d) }.first
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
