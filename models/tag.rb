require_relative('../db/sql_runner')

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
end
