class Student

  ATTRIBUTES = {
    :id => "INTEGER PRIMARY KEY",
    :name => "TEXT",
    :tagline => "TEXT",
    :github =>  "TEXT",
    :twitter =>  "TEXT",
    :blog_url =>  "TEXT",
    :image_url  => "TEXT",
    :biography =>  "TEXT"
  }

  attr_accessor *ATTRIBUTES.keys


  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY AUTOINCREMENT, 
      name TEXT,  
      tagline TEXT, 
      github TEXT, 
      twitter TEXT, 
      blog_url TEXT, 
      image_url TEXT, 
      biography TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS students
    SQL
    DB[:conn].execute(sql)
  end
  
  def attribute_values
    ATTRIBUTES.keys[1..-1].collect{|key| self.send(key)}
  end

  def insert
    sql = "INSERT INTO students (#{ATTRIBUTES.keys[1..-1].join(",")}) VALUES (?,?,?,?,?,?,?)"
    DB[:conn].execute(sql, *attribute_values)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end

  def self.new_from_db(row)
    self.new.tap do |s|
      row.each_with_index do |value, index|
        s.send("#{ATTRIBUTES.keys[index]}=", value)
      end
    end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"
      result = DB[:conn].execute(sql,name)[0] #[]    
      self.new_from_db(result) if result
  end

  def sql_for_update
    ATTRIBUTES.keys[1..-1].collect{|k| "#{k} = ?"}.join(",")
  end

  def update
    sql = "UPDATE students SET #{sql_for_update} WHERE id = ?"
    DB[:conn].execute(sql, *attribute_values, id)
  end   

  def persisted?
    !!self.id
  end

  def save
    persisted? ? update : insert
  end

end
