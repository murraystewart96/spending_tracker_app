require('sinatra')
require('sinatra/contrib/all')
require_relative('../models/transaction')
require_relative('../models/tag')
require_relative('../models/merchant')
also_reload( '../models/*' )
require('pry')


get('/transactions') do
  @transactions = Transaction.all_sorted_by_timestamp()
  @transactions_amount = Transaction.total_cost()
  Transaction.set_visible_transactions(10)
  @month_num = 0
  @tag_id = 0
  @merchant_id = 0
  @merchants = Merchant.all()
  @tags = Tag.all()
  @user = User.get_user()
  @months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
              "Aug", "Sep", "Oct", "Nov", "Dec"]
  @transaction_view = true
  erb(:"transactions/index")
end

post ('/transactions/:id/update') do
  @transaction = Transaction.new(params)
  @transaction.update()
  erb(:"transactions/show")
end


get('/transactions/load-more') do
  @transactions = Transaction.all_sorted_by_timestamp()
  @transactions_amount = Transaction.total_cost()
  @merchants = Merchant.all()
  @tags = Tag.all()
  @user = User.get_user()
  @months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
              "Aug", "Sep", "Oct", "Nov", "Dec"]
  @transaction_view = true
  Transaction.set_visible_transactions(Transaction.get_visible_transactions() + 10)
  erb(:"transactions/index")
end

get('/transactions/monthly-spending') do
  @months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
              "Aug", "Sep", "Oct", "Nov", "Dec"]
  @user = User.get_user()
  @tags = Tag.all()
  @merchants = Merchant.all()
  @transactions = Transaction.all_sorted_by_timestamp()
  @transactions_amount = Transaction.total_cost()


  @monthly_spending_view = true
  @months_spending = Transaction.monthly_spending()
  @average_monthly_spending = Transaction.average_monthly_spending()

  @each_tags_monthly_cost = Tag.monthly_spending_for_each_tag()
  @each_merchants_monthly_cost = Merchant.monthly_spending_for_each_merchant()

  erb(:"transactions/index")

end

get('/transactions/new') do
  @merchants = Merchant.all()
  @tags = Tag.all()
  erb(:"transactions/new")
end

get('/transactions/new/failed') do
  @transaction_failed = true
  @merchants = Merchant.all()
  @tags = Tag.all()
  erb(:"transactions/new")
end


post('/transactions') do
  transaction = Transaction.new(params)
  @user = User.get_user()
  @transaction_view = true

  if (@user.can_afford(transaction.amount))
    @user.pay_for_transaction(transaction.amount)
    transaction.save()

    @balance_warning = @user.balance_warning()
    if(@balance_warning)
      redirect('/users/add-funds')
    end
    redirect('/transactions')
  else
    redirect('/transactions/new/failed')
  end
end


get ('/transactions/failed') do
  erb(:"transactions/")
end

get ('/transactions/:id/edit') do
  id = params['id'].to_i()
  @merchants = Merchant.all()
  @tags = Tag.all()
  @transaction = Transaction.find_by_id(id)
  erb(:"transactions/edit")
end


#INDEX
post('/transactions/filtered') do

  #data that is required for the view every time
  @months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
              "Aug", "Sep", "Oct", "Nov", "Dec"]
  @tags = Tag.all()
  @user = User.get_user()
  @merchants = Merchant.all()


  #Extracting the filter parameters
  @month_num = params['month_num'].to_i()
  @tag_id = params['tag_id'].to_i()
  @merchant_id = params['merchant_id'].to_i()

  #The month, tag and merchant specified by the filter
  @month = @months[@month_num-1]
  @tag = Tag.find_by_id(@tag_id) if (@tag_id != 0)
  @merchant = Merchant.find_by_id(@merchant_id) if (@merchant_id != 0)

  #Information for display output
  @month_filter_name = "(#{@months[@month_num-1]})" if (@month_num != 0)
  @tag_filter_name = "(#{@tag.name})" if (@tag_id != 0)
  @merchant_filter_name = "(#{@merchant.name})" if (@merchant_id != 0)
  @filtered = true if(@tag_id != 0 || @merchant_id != 0 || @month_num !=0)

  #filetered transactions to be displayed
  @transactions = Transaction.transactions_filtered(@month_num, @tag_id, @merchant_id)
  @transactions_amount = Transaction.sum_transactions(@transactions)
  @transaction_view = true

  erb(:"transactions/index")
end


### FIX TRAILING / ###
post('/transactions/filtered/sorted/') do

  @months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
              "Aug", "Sep", "Oct", "Nov", "Dec"]

  @tags = Tag.all()
  @user = User.get_user()
  @merchants = Merchant.all()

  @sort_by = params['sort_by']
  @month_num = params['month_num'].to_i()
  @tag_id = params['tag_id'].to_i()
  @merchant_id = params['merchant_id'].to_i()

  @month = @months[@month_num-1]
  @tag = Tag.find_by_id(@tag_id) if (@tag_id != 0)
  @merchant = Merchant.find_by_id(@merchant_id) if (@merchant_id != 0)

  @month_filter_name = "(#{@months[@month_num-1]})" if (@month_num != 0)
  @tag_filter_name = "(#{@tag.name})" if (@tag_id != 0)
  @merchant_filter_name = "(#{@merchant.name})" if (@merchant_id != 0)
  @filtered = true if(@tag_id != 0 || @month_num != 0 || @merchant_id != 0)


  @transactions = Transaction.all_sorted_by_timestamp(@sort_by)
  @transactions_amount = Transaction.total_cost()
  @transaction_view = true
  erb(:"transactions/index")
end


post('/transactions/filtered/sorted/:month_num/:tag_id/:merchant_id') do
  @months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
              "Aug", "Sep", "Oct", "Nov", "Dec"]

  @tags = Tag.all()
  @user = User.get_user()
  @merchants = Merchant.all()

  @sort_by = params['sort_by']
  @month_num = params['month_num'].to_i()
  @tag_id = params['tag_id'].to_i()
  @merchant_id = params['merchant_id'].to_i()

  @month = @months[@month_num-1]
  @tag = Tag.find_by_id(@tag_id) if (@tag_id != 0)
  @merchant = Merchant.find_by_id(@merchant_id) if (@merchant_id != 0)

  @month_filter_name = "(#{@months[@month_num-1]})" if (@month_num != 0)
  @tag_filter_name = "(#{@tag.name})" if (@tag_id != 0)
  @merchant_filter_name = "(#{@merchant.name})" if (@merchant_id != 0)
  @filtered = true if(@tag_id != 0 || @month_num != 0 || @merchant_id != 0)


  @transactions = Transaction.transactions_filtered(@month_num, @tag_id, @merchant_id)
  @transactions_amount = Transaction.sum_transactions(@transactions)
  @transaction_view = true
  erb(:"transactions/index")

end


get('/transactions/filtered/:month_num') do
  @months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
              "Aug", "Sep", "Oct", "Nov", "Dec"]

  @tags = Tag.all()
  @user = User.get_user()
  @merchants = Merchant.all()

  @month_num = params['month_num'].to_i()
  @tag_id = 0
  @merchant_id = 0

  @month = @months[@month_num-1]

  #Information for display output
  @month_filter_name = "(#{@months[@month_num-1]})" if (@month_num != 0)
  @tag_filter_name = "(#{@tag.name})" if (@tag_id != 0)
  @merchant_filter_name = "(#{@merchant.name})" if (@merchant_id != 0)
  @filtered = true if(@tag_id != 0 || @merchant_id != 0 || @month_num !=0)

  @transactions = Transaction.transactions_filtered(@month_num, 0, 0)
  @transactions_amount = Transaction.sum_transactions(@transactions)
  @transaction_view = true
  erb(:"transactions/index")

end
