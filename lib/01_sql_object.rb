require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'

# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL).first.map(&:to_sym)
      SELECT
        *
      FROM
        "#{table_name}"
    SQL
  end

  def self.finalize!
    columns.each do |column|
      define_method column.to_sym do
        attributes[column]
      end

      define_method "#{column}=" do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || to_s.tableize
  end

  def self.all
    parse_all DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        "#{table_name}"
    SQL
  end

  def self.parse_all(results)
    results.map { |row| new(row) }
  end

  def self.find(id)
    all.find { |instance| instance.id == id }
  end

  def initialize(params = {})
    params.each do |k, v|
      cols = self.class.columns
      raise "unknown attribute '#{k}'" unless cols.include?(k.to_sym)

      send("#{k}=", v)
    end
  end

  def attributes
    @attributes ||= {}
  end

  # TODO: The instructions describe this differently
  # * I wrote a `SQLObject#attribute_values` method that returns an array
  # of the values for each attribute. I did this by calling `Array#map`
  # on `SQLObject::columns`, calling `send` on the instance to get
  # the value.
  def attribute_values
    @attributes.values
  end

  def insert
    cols_without_id = self.class.columns.drop(1)
    col_names = cols_without_id.join(', ')
    question_marks = (['?'] * cols_without_id.length).join(', ')

    DBConnection.execute(<<-SQL, attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    # TODO: Why doesn't `@id = ` work?
    self.id = DBConnection.last_insert_row_id
  end

  def update
    cols_atts = self.class.columns.zip(attribute_values)
    set_line = cols_atts.map { |k, v| "#{k} = '#{v}'" }.join(', ')

    DBConnection.execute(<<-SQL)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = #{id}
    SQL
  end

  def save
    id.nil? ? insert : update
  end
end
