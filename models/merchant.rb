require_relative('../db/sql_runner')

class Merchant

  attr_reader :id
  attr_accessor :name

  def initialize(info)
    @id = info['id'].to_i() if info['id']
    @name = info['name']
  end


  def save()
    sql_query = "INSERT INTO merchants (name)
    VALUES ($1) RETURNING id"
    values = [@name]
    result = SqlRunner.run(sql_query, values)
    @id = result[0]['id'].to_i()
  end

  def self.delete_all()
    sql_query = "DELETE FROM merchants;"
    SqlRunner.run(sql_query)
  end

  def self.all()
    sql_query = "SELECT * FROM merchants"
    merchants_info = SqlRunner.run(sql_query)
    return merchants_info.map{|merchant_info| Merchant.new(merchant_info)}
  end

  def self.find_by_id(id)
    sql_query = "SELECT *
    FROM merchants
    WHERE id = $1"
    values = [id]
    merchant_info = SqlRunner.run(sql_query, values)[0]
    return Merchant.new(merchant_info)
  end


  def self.monthly_spending_for_each_merchant()
    merchants = Merchant.all()
    merchants_monthly_spending = []
    for merchant in merchants
      merchants_monthly_spending.push(Transaction.monthly_spending_for_merchant(merchant.id))
    end

    return merchants_monthly_spending
  end


  def average_monthly_spending()
    merchants_monthly_spending = (Transaction.monthly_spending_for_merchant(@id))
    return (merchants_monthly_spending.sum() / 12.0).round(2)
  end

end
