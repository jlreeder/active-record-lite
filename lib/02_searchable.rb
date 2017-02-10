require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    matches = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        cats
      WHERE
        name = 'Breakfast'
    SQL

    matches.map { |res| new(res) }
  end
end

class SQLObject
  extend Searchable
  # Mixin Searchable here...
end
