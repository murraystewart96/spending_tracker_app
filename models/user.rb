require_relative('../db/sql_runner')

class User

  attr_reader :id
  attr_accessor :first_name, :last_name, :balance
  def initialize(info)
    @id = info['id'].to_i() if info['id']
    @first_name = info['first_name']
    @last_name = info['last_name']
    @balance = info['balance'].to_f().round(2) if info['balance']
    @balance_warning = info['balance_warning'].to_f()
  end


  def save()
    sql_query = "INSERT INTO users (first_name, last_name, balance_warning)
    VALUES ($1, $2, $3) RETURNING id"
    values = [@first_name, @last_name, @balance_warning]
    result = SqlRunner.run(sql_query, values)
    @id = result[0]['id'].to_i()
  end


  def self.delete_all()
    sql_query = "DELETE FROM users;"
    SqlRunner.run(sql_query)
  end


  def self.get_user()
    sql_query = "SELECT * FROM users;"
    user_info = SqlRunner.run(sql_query)[0]
    return User.new(user_info)
  end


  def can_afford(amount)
    if (@balance - amount >= 0)
      return true
    end
    return false
  end


  def balance_warning()
    if(@balance <= @balance_warning)
      return "Warning! Your balance is £#{@balance}"
    end

    return nil
  end


  def pay_for_transaction(amount)
    @balance -= amount.to_f()
    @balance.round(2)
    update()
  end

  def update()
    sql_query = "UPDATE users
    SET (first_name, last_name, balance_warning, balance)
    = ($1, $2, $3, $4)
    WHERE id = $5"
    values = [@first_name, @last_name, @balance_warning, @balance, @id]
    SqlRunner.run(sql_query, values)
  end
end
