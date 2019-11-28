require_relative('../db/sql_runner')
require_relative('merchant')
require_relative('tag')

class Transaction

  attr_reader :id, :merchant_id, :tag_id
  attr_accessor :description, :amount, :date

  def initialize(info)
    @id = info['id'].to_i() if info['id']
    @description = info['description']
    @amount = info['amount'].to_i()
    @date = info['date_of_transaction']
    @merchant_id = info['merchant_id']
    @tag_id = info['tag_id']
  end

  def save()
    sql_query = "INSERT INTO transactions
    (description, amount, date_of_transaction, merchant_id, tag_id)
    VALUES ($1, $2, $3, $4, $5) RETURNING id"
    values = [@description, @amount, @date, @merchant_id, @tag_id]
    result = SqlRunner.run(sql_query, values)
    @id = result[0]['id'].to_i()
  end

  def self.delete_all()
    sql_query = "DELETE FROM transactions;"
    SqlRunner.run(sql_query)
  end

  def self.all()
    sql_query = "SELECT * FROM transactions"
    transactions_info = SqlRunner.run(sql_query)
    return transactions_info.map{|trans_info| Transaction.new(trans_info)}
  end

  def merchant()
    return Merchant.find_by_id(@merchant_id)
  end

  def tag()
    return Tag.find_by_id(@tag_id)
  end

end
