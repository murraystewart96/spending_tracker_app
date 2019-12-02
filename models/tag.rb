require_relative('../db/sql_runner')
require_relative('transaction')

class Tag

  attr_reader :id
  attr_accessor :name

  def initialize(info)
    @id = info['id'].to_i() if info['id']
    @name = info['name']
  end

  def save()
    sql_query = "INSERT INTO tags (name)
    VALUES ($1) RETURNING id"
    values = [@name]
    result = SqlRunner.run(sql_query, values)
    @id = result[0]['id'].to_i()
  end

  def self.delete_all()
    sql_query = "DELETE FROM tags;"
    SqlRunner.run(sql_query)
  end

  def self.all()
    sql_query = "SELECT * FROM tags"
    tags_info = SqlRunner.run(sql_query)
    return tags_info.map{|tag_info| Tag.new(tag_info)}
  end

  def self.find_by_id(id)
    sql_query = "SELECT *
    FROM tags
    WHERE id = $1"
    values = [id]

    tag_info = SqlRunner.run(sql_query, values)[0]
    return Tag.new(tag_info)
  end


  def transactions()
    sql_query = "SELECT *
    FROM transactions
    WHERE tag_id = $1;"
    values = [@id]
    transactions_info = SqlRunner.run(sql_query, values)
    return transactions_info.map{|info| Transaction.new(info)}
  end

  def transactions_in_month(month)
    sql_query = "SELECT *
    FROM transactions
    WHERE EXTRACT (MONTH FROM transaction_timestamp) = $1
    AND tag_id = $2"

    if(month.digits() == 1)
      new_month = "0"+ month.to_s()
      month = new_month.to_i()
    end

    values = [month, @id]
    transactions_info = SqlRunner.run(sql_query, values)

    return transactions_info.map{|trans_info| Transaction.new(trans_info)}
  end


  def transactions_sum()
    running_total = 0
    for transaction in transactions()
      running_total += transaction.amount
    end
    return running_total
  end


end
