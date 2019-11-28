require('sinatra')
require('sinatra/contrib/all')
require_relative('../models/transaction')
also_reload( '../models/*' )
require('pry')


get('/transactions') do
  @transactions = Transaction.all()
  # binding.pry
  erb(:"transactions/index")
end
