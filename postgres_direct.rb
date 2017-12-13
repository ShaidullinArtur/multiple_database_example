class PostgresDirect
  def find_user(user_id)
    users_connect.exec("SELECT users.* FROM users WHERE users.id = #{user_id} LIMIT 1") do |result|
      yield result.first if block_given?
      result.first
    end
  end

  def find_user_activities(user_id, options = {})
    find_user(user_id) do |row|
      activities_connect.exec(prepare_user_activities_query(user_id, options)) do |result|
        yield result if block_given?
      end
    end
  end

  def disconnect
    @users_connect.close if @users_connect
    @activities_connect.close if @activities_connect
  end

  private

  def prepare_user_activities_query(user_id, options = {})
    <<-SQL
      SELECT activities.*
      FROM activities
      WHERE activities.user_id = #{user_id}
      LIMIT #{options[:limit]}
      OFFSET #{options[:offset]}
    SQL
  end

  def users_connect
    @users_connect ||= PG.connect(
      host: "ec2-54-163-224-150.compute-1.amazonaws.com",
      port: 5432,
      dbname: "d60kphefmif8ne",
      user: "kgjioftaopjorj",
      password: "fcbe69c4702bd1c71c077bd55646d1dcb0237ece2723c4edeb317add2d49d48d"
    )
  end

  def activities_connect
    @activities_connect ||= PG.connect(
      host: "ec2-54-163-224-150.compute-1.amazonaws.com",
      port: 5432,
      dbname: "d1vc630hdu253p",
      user: "aazformoebihvm",
      password: "1c0e288ea09ddc29275e909dd8d7bafed91c13bda2b53eca926405566a78c8f6"
    )
  end
end