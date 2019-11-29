require('sinatra')
require('sinatra/contrib/all')
require_relative('../models/transaction')
require_relative('../models/tag')
require_relative('../models/merchant')
also_reload( '../models/*' )
require('pry')


get('/transactions') do
  @transactions = Transaction.all_ordered_by_timestamp()
  @total_amount = Transaction.total_amount()
  @merchants = Merchant.all()
  @tags = Tag.all()
  @months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
              "Aug", "Sep", "Oct", "Nov", "Dec"]
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

post('/transactions/filter') do

  @transactions = []
  month_num = params['month_num'].to_i()
  tag_id = params['tag_id'].to_i()
  if(month_num)
    @transactions = Transaction.find_transactions_for_month(month_num)
  end

  if(tag_id)
    @transactions = 
  end

  @tags = Tag.all()
  @months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
              "Aug", "Sep", "Oct", "Nov", "Dec"]

  erb(:"transactions/index")
end


post('/transactions/sorted') do
  sort_by = params['sort_by']

  @transactions = Transaction.all_ordered_by_timestamp(sort_by)

  @total_amount = Transaction.total_amount()

  erb(:"transactions/index")
end
