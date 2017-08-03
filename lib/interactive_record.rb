require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def save
    sql = <<-SQL
    INSERT INTO students
    VALUES (?, ?, ?)
    SQL

    DB[:conn].execute(sql, id, self.name, self.grade)

    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]

  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    "name, grade"
  end

  def values_for_insert
    "'#{self.name}', '#{self.grade}'"
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students
    WHERE students.name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []

    table_info.each do |column|
      column_names << column["name"]
    end

    column_names.compact

  end

  def self.find_by(attribute)
    puts "column = #{"students.#{attribute.keys[0].to_s}"}"
    puts "value = #{attribute.values[0].to_s}"

    DB[:conn].execute("SELECT * FROM students WHERE students.#{attribute.keys[0].to_s} = '#{attribute.values[0].to_s}'")
  end


end
