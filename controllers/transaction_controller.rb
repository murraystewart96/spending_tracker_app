require('sinatra')
require('sinatra/contrib/all')
require_relative('../models/transaction')
require_relative('../models/tag')
require_relative('../models/merchant')
also_reload( '../models/*' )
require('pry')

#INDEX
get('/transactions') do
  #all transactions to be displayed
  #and the total cost
  @transactions = Transaction.all_sorted_by_timestamp()
  @transactions_amount = Transaction.total_cost()
  Transaction.set_visible_transactions(10)

  #months for the filter
  @months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
              "Aug", "Sep", "Oct", "Nov", "Dec"]

  #initializing filter information
  @month_num = 0
  @tag_id = 0
  @merchant_id = 0

  #getting data for filter dropdown
  @merchants = Merchant.all()
  @tags = Tag.all()
  @user = User.get_user()

  #setting transaction view (opposed to montly)
  @transaction_view = true
  erb(:"transactions/index")
end


#SHOW
post ('/transactions/:id/update') do
  @transaction = Transaction.new(params)
  @transaction.update()
  erb(:"transactions/show")
end

#INDEX
#Same as '/transaction' but with 10
#more transactions visible than there was previously
#increases by 10 on successively
get('/transactions/load-more') do
  @transactions = Transaction.all_sorted_by_timestamp()
  @transactions_amount = Transaction.total_cost()
  @month_num = 0
  @tag_id = 0
  @merchant_id = 0
  @merchants = Merchant.all()
  @tags = Tag.all()
  @user = User.get_user()
  @months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
              "Aug", "Sep", "Oct", "Nov", "Dec"]
  @transaction_view = true
  Transaction.set_visible_transactions(Transaction.get_visible_transactions() + 10)
  erb(:"transactions/index")
end

get('/transactions/load-more/:sort_by') do
  #Extracting the filter parameters
  @sort_by = params['sort_by']
  @transactions = Transaction.all_sorted_by_timestamp(@sort_by)
  @transactions_amount = Transaction.total_cost()
  @month_num = 0
  @tag_id = 0
  @merchant_id = 0
  @merchants = Merchant.all()
  @tags = Tag.all()
  @user = User.get_user()
  @months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
              "Aug", "Sep", "Oct", "Nov", "Dec"]
  @transaction_view = true
  Transaction.set_visible_transactions(Transaction.get_visible_transactions() + 10)
  erb(:"transactions/index")
end


#INDEX
#gets information for monthly spending table
get('/transactions/monthly-spending') do
  #data that is required for the view every time
  @months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
              "Aug", "Sep", "Oct", "Nov", "Dec"]
  @user = User.get_user()
  @tags = Tag.all()
  @merchants = Merchant.all()

  #all transactions and total cost
  @transactions = Transaction.all_sorted_by_timestamp()
  @transactions_amount = Transaction.total_cost()

  #activate monthly spending view
  #retrieve monthly spending data
  @monthly_spending_view = true
  @months_spending = Transaction.monthly_spending()
  @average_monthly_spending = Transaction.average_monthly_spending()
  @each_tags_monthly_cost = Tag.monthly_spending_for_each_tag()
  @each_merchants_monthly_cost = Merchant.monthly_spending_for_each_merchant()

  erb(:"transactions/index")

end


#NEW
get('/transactions/new') do
  @merchants = Merchant.all()
  @tags = Tag.all()
  erb(:"transactions/new")
end


#NEW
get('/transactions/new/failed') do
  @transaction_failed = true
  @merchants = Merchant.all()
  @tags = Tag.all()
  erb(:"transactions/new")
end


#
post('/transactions') do
  transaction = Transaction.new(params)
  @user = User.get_user()
  @transaction_view = true

  #pay for transaction if user can afford
  if (@user.can_afford(transaction.amount))
    @user.pay_for_transaction(transaction.amount)
    transaction.save()

    #Redirect depending on wether the transaction was succesfull
    #or not. Or succesfull bull balance is now under the warning
    #limit
    @balance_warning = @user.balance_warning()
    if(@balance_warning)
      redirect('/users/add-funds')
    end
    redirect('/transactions')
  else
    redirect('/transactions/new/failed')
  end
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



post('/transactions/filtered/sorted/:month_num/:tag_id/:merchant_id') do
  #data that is required for the view every time
  @months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
              "Aug", "Sep", "Oct", "Nov", "Dec"]
  @tags = Tag.all()
  @user = User.get_user()
  @merchants = Merchant.all()

  #Extracting the filter parameters
  @sort_by = params['sort_by']
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
  @filtered = true if(@tag_id != 0 || @month_num != 0 || @merchant_id != 0)

  #filetered transactions to be displayed
  @transactions = Transaction.transactions_filtered(@month_num, @tag_id, @merchant_id, @sort_by)
  @transactions_amount = Transaction.sum_transactions(@transactions)
  @transaction_view = true
  erb(:"transactions/index")

end


get('/transactions/filtered/:month_num') do
  #data that is required for the view every time
  @months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
              "Aug", "Sep", "Oct", "Nov", "Dec"]
  @tags = Tag.all()
  @user = User.get_user()
  @merchants = Merchant.all()

  #Extracting and initializing filter parameters
  @month_num = params['month_num'].to_i()
  @tag_id = 0
  @merchant_id = 0

  #month to be viewed
  @month = @months[@month_num-1]

  #Information for display output
  @month_filter_name = "(#{@months[@month_num-1]})" if (@month_num != 0)
  @tag_filter_name = "(#{@tag.name})" if (@tag_id != 0)
  @merchant_filter_name = "(#{@merchant.name})" if (@merchant_id != 0)
  @filtered = true if(@tag_id != 0 || @merchant_id != 0 || @month_num !=0)

  #filetered transactions to be displayed
  @transactions = Transaction.transactions_filtered(@month_num, 0, 0)
  @transactions_amount = Transaction.sum_transactions(@transactions)
  @transaction_view = true
  erb(:"transactions/index")

end
