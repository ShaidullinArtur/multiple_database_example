require "thor"
require "pg"
require_relative "postgres_direct"

class TestTask < Thor
  desc "Find User by Id", "find user data"
  def find_user(user_id)
    postgres_direct.find_user(user_id) do |data|
      return puts "Can't find user with id=#{user_id}" unless data

      puts "Id: #{data["id"]}"
      puts "Created At: #{data["created_at"]}"
      puts "Token: #{data["token"]}"
    end
  ensure
    postgres_direct.disconnect
  end

  desc "user activities", "get list of user activities"
  method_option :limit, type: :numeric, desc: "choose results size", default: 10
  method_option :offset, type: :numeric, desc: "choose results offset", default: 0
  def user_activities(user_id)
    postgres_direct.find_user_activities(user_id, options) do |rows|
      return puts "User with id=#{user_id} hasn't got any activities" unless rows.any?

      rows.each do |row|
        puts "Id: #{row["id"]}, Kind: #{row["kind"]}, Message: #{row["message"]}"
      end
    end
  ensure
    postgres_direct.disconnect
  end

  private

  def postgres_direct
    @postgres_direct ||= PostgresDirect.new
  end
end
