require_relative "pg_relation"

class Activity < PGRelation
  private

  def table_name
    "app.activities"
  end

  def connection
    @connection ||= PG.connect(host: "localhost", dbname: "multiple-database-dev")
  end
end
