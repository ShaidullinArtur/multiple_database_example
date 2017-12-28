require "pg"

class PGRelation
  COMMON_SQL_METHODS = %i(select filter group_by).freeze

  def initialize
    @sql_parts = { select: [], filter: [], group_by: [] }
  end

  def load
    connection.exec(sql)
  ensure
    connection.close
  end

  def sql
    @sql_parts.reduce("") do |sql_query, (key, value)|
      send("apply_#{key}_conditions", sql_query, value)
    end
  end

  private

  def table_name
    raise NotImplementedError.new("You must implement table name.")
  end

  def apply_select_conditions(sql_query, values)
    columns = values.empty? ? "* " : values.join(", ")
    sql_query += "SELECT #{columns} FROM #{table_name}"
  end

  def apply_filter_conditions(sql_query, values)
    return sql_query if values.empty?
    sql_query += " WHERE " + values.join(" AND ")
  end

  def apply_group_by_conditions(sql_query, values)
    return sql_query if values.empty?
    sql_query += " GROUP BY " + values.join(", ")
  end

  def connection
    raise NotImplementedError.new("You must implement connection.")
  end

  def method_missing(method_name, *args)
    common_sql_method(method_name, args)
  end

  def common_sql_method(method_name, *args)
    self.tap do
      @sql_parts[method_name.to_sym] << args
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    COMMON_SQL_METHODS.include?(method_name) || super
  end
end
