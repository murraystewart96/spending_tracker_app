require_relative('../db/sql_runner')
require_relative('merchant')
require_relative('tag')

class Transaction

  attr_reader :id, :merchant_id, :tag_id
  attr_accessor :description, :amount, :date, :visible_transactions
  @@visible_transactions = 10

  def initialize(info)
    @id = info['id'].to_i() if info['id']
    @description = info['description']
    @amount = info['amount'].to_i()
    @date = info['transaction_timestamp']
    @merchant_id = info['merchant_id'].to_i()
    @tag_id = info['tag_id'].to_i()

  end

  def self.get_visible_transactions()
    return @@visible_transactions
  end

  def self.set_visible_transactions(amount)
    @@visible_transactions = amount
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

  def update ()
    sql_query = "UPDATE transactions
    SET (description, amount, transaction_timestamp, merchant_id, tag_id)
    = ($1, $2, CURRENT_TIMESTAMP, $3, $4)
    WHERE id = $5"
    values = [@description, @amount, @merchant_id,
              @tag_id, @id]
    SqlRunner.run(sql_query, values)
  end


  def self.find_by_id(id)
    sql_query = "SELECT *
    FROM transactions
    WHERE id = $1"
    values = [id]

    trans_info = SqlRunner.run(sql_query, values)[0]
    return Transaction.new(trans_info)
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



  def self.transactions_filtered(month_num, tag_id, merchant_id, sort_by = 'newest')

    filter_options = {
      'month' => month_num,
      'tag' => tag_id,
      'merchant' => merchant_id
    }

    filter_combinations = ["month tag", "month merchant", "tag merchant"]

    active_filter = ""
    filter_count = 0

    filter_options.each do |filter, value|
      if (value != 0)
        active_filter += filter + " "
        filter_count += 1
      end
    end

    if(filter_count == 0)
      transactions = Transaction.all_sorted_by_timestamp(sort_by)
    elsif(filter_combinations.include?(active_filter.strip!()))
      if(filter_combinations.index(active_filter) == 0)
        transactions = Transaction.select_by_tag_and_month(tag_id, month_num, sort_by)
      elsif(filter_combinations.index(active_filter) == 1)
        transactions = Transaction.select_by_month_and_merchant(merchant_id, month_num, sort_by)
      elsif(filter_combinations.index(active_filter) == 2)
        transactions = Transaction.select_by_tag_and_merchant(tag_id, merchant_id, sort_by)
      end
    elsif(filter_count == 1)
      if(filter_options['month'] != 0)
        transactions = Transaction.select_by_month(month_num, sort_by)
      elsif(filter_options['tag'] != 0)
        transactions = Transaction.select_by_tag_id(tag_id, sort_by)
      elsif(filter_options['merchant'] != 0)
        transactions = Transaction.select_by_merchant(merchant_id, sort_by)
      end
    else
      transactions = Transaction.select_by_all(tag_id, merchant_id, month_num, sort_by)
    end
    return transactions
  end


  def time()
    timestamp = timestamp()
    return timestamp.split(' ')[1]
  end

  def self.total_cost()
    sql_query = "SELECT SUM(amount)
    FROM transactions;"
    result = SqlRunner.run(sql_query)[0]
    return result['sum']
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
      sql_query = "SELECT SUM(amount) FROM transactions
      WHERE EXTRACT (MONTH FROM transaction_timestamp) = $1"
      values = [month_num]
      result = SqlRunner.run(sql_query, values)[0]
      months_spending.push(result['sum'].to_f())
    end

    return months_spending
  end


  def self.monthly_spending_for_tag(tag_id)
    months_spending = []

    for month_num in 1..12
      sql_query = "SELECT SUM(amount) FROM transactions
      WHERE EXTRACT (MONTH FROM transaction_timestamp) = $1
      AND tag_id = $2"
      values = [month_num, tag_id]
      result = SqlRunner.run(sql_query, values)[0]
      months_spending.push(result['sum'].to_f())
    end

    return months_spending
  end



  def self.monthly_spending_for_merchant(merchant_id)
    months_spending = []

    for month_num in 1..12
      sql_query = "SELECT SUM(amount) FROM transactions
      WHERE EXTRACT (MONTH FROM transaction_timestamp) = $1
      AND merchant_id = $2"
      values = [month_num, merchant_id]
      result = SqlRunner.run(sql_query, values)[0]
      months_spending.push(result['sum'].to_f())
    end

    return months_spending
  end


  def self.average_monthly_spending()
    spending = Transaction.monthly_spending()
    spending.delete(0)
    return (spending.sum() / spending.size().to_f()).round(2)
  end



  def self.select_by_month(month, sort_by)

    if (sort_by == "newest")
      sql_query = "SELECT *
      FROM transactions
      WHERE EXTRACT (MONTH FROM transaction_timestamp) = $1
      ORDER BY transaction_timestamp
      DESC;"
    elsif (sort_by == "oldest")
      sql_query = "SELECT *
      FROM transactions
      WHERE EXTRACT (MONTH FROM transaction_timestamp) = $1
      ORDER BY transaction_timestamp
      ASC;"
    end


    if(month.digits() == 1)
      new_month = "0"+ month.to_s()
      month = new_month.to_i()
    end

    values = [month]
    transactions_info = SqlRunner.run(sql_query, values)
    return transactions_info.map{|trans_info| Transaction.new(trans_info)}
  end


  def self.select_by_tag_id(tag_id, sort_by)
    if (sort_by == "newest")
      sql_query = "SELECT *
      FROM transactions
      WHERE tag_id = $1
      ORDER BY transaction_timestamp
      DESC"
    elsif (sort_by == "oldest")
      sql_query = "SELECT *
      FROM transactions
      WHERE tag_id = $1
      ORDER BY transaction_timestamp
      ASC"
    end

    values = [tag_id]
    transactions_info = SqlRunner.run(sql_query, values)
    return transactions_info.map{|trans_info| Transaction.new(trans_info)}
  end


  def self.select_by_merchant(merchant_id, sort_by)
    if (sort_by == "newest")
      sql_query = "SELECT *
      FROM transactions
      WHERE merchant_id = $1
      ORDER BY transaction_timestamp
      DESC"
    elsif (sort_by == "oldest")
      sql_query = "SELECT *
      FROM transactions
      WHERE merchant_id = $1
      ORDER BY transaction_timestamp
      ASC"
    end

    values = [merchant_id]
    transactions_info = SqlRunner.run(sql_query, values)
    return transactions_info.map{|trans_info| Transaction.new(trans_info)}

  end



  def self.select_by_tag_and_month(tag_id, month, sort_by)

    if (sort_by == "newest")
      sql_query = "SELECT *
      FROM transactions
      WHERE EXTRACT (MONTH FROM transaction_timestamp) = $1
      AND tag_id = $2
      ORDER BY transaction_timestamp
      DESC"
    elsif (sort_by == "oldest")
      sql_query = "SELECT *
      FROM transactions
      WHERE EXTRACT (MONTH FROM transaction_timestamp) = $1
      AND tag_id = $2
      ORDER BY transaction_timestamp
      ASC"
    end

    if(month.digits() == 1)
      new_month = "0"+ month.to_s()
      month = new_month.to_i()
    end

    values = [month, tag_id]
    transactions_info = SqlRunner.run(sql_query, values)

    return transactions_info.map{|trans_info| Transaction.new(trans_info)}
  end


  def self.select_by_month_and_merchant(merchant_id, month, sort_by)

    if (sort_by == "newest")
      sql_query = "SELECT *
      FROM transactions
      WHERE EXTRACT (MONTH FROM transaction_timestamp) = $1
      AND merchant_id = $2
      ORDER BY transaction_timestamp
      DESC"
    elsif (sort_by == "oldest")
      sql_query = "SELECT *
      FROM transactions
      WHERE EXTRACT (MONTH FROM transaction_timestamp) = $1
      AND tag_id = $2
      ORDER BY transaction_timestamp
      ASC"
    end

    if(month.digits() == 1)
      new_month = "0"+ month.to_s()
      month = new_month.to_i()
    end

    values = [month, merchant_id]
    transactions_info = SqlRunner.run(sql_query, values)

    return transactions_info.map{|trans_info| Transaction.new(trans_info)}
  end


  def self.select_by_tag_and_merchant(tag_id, merchant_id, sort_by)

    if (sort_by == "newest")
      sql_query = "SELECT *
      FROM transactions
      WHERE tag_id = $1
      AND merchant_id = $2
      ORDER BY transaction_timestamp
      DESC"
    elsif (sort_by == "oldest")
      sql_query = "SELECT *
      FROM transactions
      WHERE tag_id = $1
      AND tag_id = $2
      ORDER BY transaction_timestamp
      ASC"
    end

    values = [tag_id, merchant_id]
    transactions_info = SqlRunner.run(sql_query, values)

    return transactions_info.map{|trans_info| Transaction.new(trans_info)}
  end


  def self.select_by_all(tag_id, merchant_id, month, sort_by)
    if (sort_by == "newest")
      sql_query = "SELECT *
      FROM transactions
      WHERE EXTRACT (MONTH FROM transaction_timestamp) = $1
      AND merchant_id = $2
      AND tag_id = $3
      ORDER BY transaction_timestamp
      DESC"
    elsif (sort_by == "oldest")
      sql_query = "SELECT *
      FROM transactions
      WHERE EXTRACT (MONTH FROM transaction_timestamp) = $1
      AND tag_id = $2
      AND tag_id = $3
      ORDER BY transaction_timestamp
      ASC"
    end

    if(month.digits() == 1)
      new_month = "0"+ month.to_s()
      month = new_month.to_i()
    end

    values = [month, merchant_id, tag_id]
    transactions_info = SqlRunner.run(sql_query, values)

    return transactions_info.map{|trans_info| Transaction.new(trans_info)}
  end


end
