class ApplicationController < ActionController::Base
    def submitcase
        insert_query = <<-SQL
          INSERT INTO datasets (title, body, author, created_at)
          VALUES (?, ?, ?, ?)
        SQL
    
        connection.execute insert_query,
          params['title'],
          params['body'],
          params['author'],
          Date.current.to_s
    
        redirect_to '/new-case'
      end
end
