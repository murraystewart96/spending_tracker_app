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


  def update_timestamp(timestamp)
    sql_query = "UPDATE transactions
    SET transaction_timestamp = $1
    WHERE id = $2;"
    values =[timestamp, @id]
    SqlRunner.run(sql_query, values)
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


  def self.transactions_by_month(transactions, month_num)
    trans_in_month = []
    for transaction in transactions
      month = transaction.date().split('-')[1].to_i()
      if (month == month_num)
        trans_in_month.push(transaction)
      end
    end
    return trans_in_month
  end



  def self.transactions_by_tag(transactions, tag_id)
    tag_transactions = []

    for transaction in transactions
      if (transaction.tag_id == tag_id)
        tag_transactions.push(transaction)
      end
    end
    return tag_transactions
  end


  def self.transactions_filtered(month_num, tag_id, sort_by = "newest")

    if(month_num ==0)
      transactions = Transaction.all_sorted_by_timestamp(sort_by)
    else
      transactions = Transaction.select_by_month(month_num)
    end

    if(tag_id != 0)
      transactions =  Transaction.transactions_by_tag(transactions, tag_id)
    end
    return transactions
  end


  def time()
    timestamp = timestamp()
    return timestamp.split(' ')[1]
  end


  def self.all_sorted_by_timestamp(order_by = "newest")

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

  def self.sum_transactions(transactions)
    running_total = 0
    for transaction in transactions
      running_total += transaction.amount
    end
    return running_total
  end



  def self.monthly_spending()
    months_spending = []


    for month_num in 1..12
      transactions_month = Transaction.select_by_month(month_num)
      spending = Transaction.sum_transactions(transactions_month)
      months_spending.push(spending)
    end

    return months_spending
  end


  def self.average_monthly_spending()
    spending = Transaction.monthly_spending()
    spending.delete(0)
    return (spending.sum() / spending.size().to_f()).round(2)
  end



  def self.select_by_month(month)
    sql_query = "SELECT *
    FROM transactions
    WHERE EXTRACT (MONTH FROM transaction_timestamp) = $1"

    if(month.digits() == 1)
      new_month = "0"+ month.to_s()
      month = new_month.to_i()
    end

    values = [month]
    transactions_info = SqlRunner.run(sql_query, values)
    return transactions_info.map{|trans_info| Transaction.new(trans_info)}
  end


end
