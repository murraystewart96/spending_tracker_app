require('pg')

class SqlRunner

  def self.run(sql_query, values = [])
    begin
      db = PG.connect({dbname: 'money_tracker', host: 'localhost'})
      db.prepare('query', sql_query)
      result = db.exec_prepared('query', values)
    ensure
      db.close() if db
    end
    return result
  end

end
