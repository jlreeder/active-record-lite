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
    # ...
  end

  def initialize(params = {})
    params.each do |k, v|
      # TODO: Why set it to a symbol?
      k_sym = k.to_sym
      raise "unknown attribute '#{k}'" unless self.class.columns.include?(k_sym)

      send("#{k}=", v)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
