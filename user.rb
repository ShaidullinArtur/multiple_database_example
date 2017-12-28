require_relative "pg_relation"

class User < PGRelation
  private

  def table_name
    "app.users"
  end

  def connection
    @connection ||= PG.connect(host: "localhost", dbname: "multiple-database-dev")
  end
end
