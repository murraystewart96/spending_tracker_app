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
    @date = info['transaction_timestamp']
    @merchant_id = info['merchant_id'].to_i()
    @tag_id = info['tag_id'].to_i()
  end

  def save()
    sql_query = "INSERT INTO transactions
    (description, amount, transaction_timestamp, merchant_id, tag_id)
    VALUES ($1, $2, CURRENT_TIMESTAMP, $3, $4) RETURNING id"
    values = [@description, @amount, @merchant_id, @tag_id]
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


  def timestamp()
    sql_query = "SELECT transaction_timestamp
    FROM transactions
    WHERE id = $1"
    values = [@id]
    timestamp_info = SqlRunner.run(sql_query, values)
    return timestamp_info[0]['transaction_timestamp'].split('.')[0]
  end

  def date()
    timestamp = timestamp()
    return timestamp.split(' ')[0]
  end


  def self.find_transactions_for_month(month_num)
    transactions = Transaction.all()
    trans_in_month = []
    for transaction in transactions
      month = transaction.date().split('-')[1].to_i()
      p month
      if (month == month_num)
        trans_in_month.push(transaction)
      end
    end
    return trans_in_month
  end


  def time()
    timestamp = timestamp()
    return timestamp.split(' ')[1]
  end


  def self.all_ordered_by_timestamp(order_by = "newest")

    if (order_by == "newest")
      sql_query = "SELECT *
      FROM transactions
      ORDER BY transaction_timestamp
      DESC"
    elsif (order_by == "oldest")
      sql_query = "SELECT *
      FROM transactions
      ORDER BY transaction_timestamp
      ASC"
    end

    transactions_info = SqlRunner.run(sql_query)
    return transactions_info.map{|trans_info| Transaction.new(trans_info)}
  end


  def self.total_amount()
    transactions = Transaction.all()
    running_total = 0

    for transaction in transactions
      running_total += transaction.amount
    end

    return running_total + 0.0
  end

end
