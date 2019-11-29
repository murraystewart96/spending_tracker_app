require('sinatra')
require('sinatra/contrib/all')
require_relative('../models/transaction')
also_reload( '../models/*' )
require('pry')


get('/transactions') do
  @transactions = Transaction.all_ordered_by_timestamp()
  @total_amount = Transaction.total_amount()
  # binding.pry
  erb(:"transactions/index")
end


get('/transactions/new') do
  @merchants = Merchant.all()
  @tags = Tag.all()
  erb(:"transactions/new")
end


post('/transactions') do
  transaction = Transaction.new(params)
  transaction.save()
  redirect('/transactions')
end


post('/transactions/ordered') do
  @transactions = Transaction.all_ordered_by_timestamp()
  @total_amount = Transaction.total_amount()
  # binding.pry
  erb(:"transactions/index")
end
