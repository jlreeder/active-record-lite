require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map { |k| "#{k} = ?"  }.join(' AND ')

    matches = DBConnection.execute(<<-SQL, params.values)
      SELECT
        *
      FROM
        cats
      WHERE
        #{where_line}
    SQL

    matches.map { |match| new(match) }
  end
end

class SQLObject
  extend Searchable
  # Mixin Searchable here...
end
