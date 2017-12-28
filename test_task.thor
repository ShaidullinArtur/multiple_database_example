require "thor"
require_relative "activity"
require_relative "user"
require_relative "search"

class TestTask < Thor
  desc "users with activities count", "get list of users with activities count"
  method_option :min_age, type: :string, desc: "choose users min age", default: nil
  def users_with_activities_count
    search = Search.new

    search.select(User, %i(id age), alias: :users) do |query, _|
      query.filter("age > #{options[:min_age]}") if options[:min_age]
    end

    search.select(Activity, ["user_id", "count(id) as activities_count"], alias: :activities) do |query, data|
      query.filter("user_id IN (#{data[:users].joined_column(:id)})")
      query.group_by("user_id")
    end

    search.merge(:users, :activities, %i(id age activities_count)) do |user_record, activity_record|
      user_record["id"] == activity_record["user_id"]
    end

    search.sort(:users_activities, :activities_count, :desc)

    search.results.each { |row| puts row }
  end
end
