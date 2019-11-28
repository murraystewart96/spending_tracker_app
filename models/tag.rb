require_relative('../db/sql_runner')

class Tag

  attr_reader :id

  def initialize(info)
    @id = info['id'].to_i() if info['id']
    @category = info['category']
  end

  def save()
    sql_query = "INSERT INTO tags (category)
    VALUES ($1) RETURNING id"
    values = [@category]
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
end
