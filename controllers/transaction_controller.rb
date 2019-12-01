require('sinatra')
require('sinatra/contrib/all')
require_relative('../models/transaction')
require_relative('../models/tag')
require_relative('../models/merchant')
also_reload( '../models/*' )
require('pry')


get('/transactions') do
  @transactions = Transaction.all_sorted_by_timestamp()
  @transactions_amount = Transaction.sum_transactions(@transactions)
  @merchants = Merchant.all()
  @tags = Tag.all()
  @user = User.get_user()
  @months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
              "Aug", "Sep", "Oct", "Nov", "Dec"]
  @transaction_view = true
  erb(:"transactions/index")
end


get('/transactions/monthly-spending') do
  @months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
              "Aug", "Sep", "Oct", "Nov", "Dec"]
  @user = User.get_user()
  @tags = Tag.all()
  @transactions = Transaction.all_sorted_by_timestamp()
  @transactions_amount = Transaction.sum_transactions(@transactions)


  @monthly_spending_view = true
  @months_spending = Transaction.monthly_spending()

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

#INDEX
post('/transactions/filtered') do

  @months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
              "Aug", "Sep", "Oct", "Nov", "Dec"]

  @tags = Tag.all()
  @user = User.get_user()

  @month_num = params['month_num'].to_i()
  @tag_id = params['tag_id'].to_i()

  @month = @months[@month_num-1]
  @tag = Tag.find_by_id(@tag_id) if (@tag_id != 0)

  @filtered_by_month_and_tag = true if(@tag_id != 0 && @month_num != 0)
  @filtered_tag_only = true if(@tag_id != 0 && @month_num == 0)
  @filtered_month_only = true if(@month_num != 0 && @tag_id == 0)

  @transactions = Transaction.transactions_filtered(@month_num, @tag_id)
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

  @sort_by = params['sort_by']
  @month_num = params['month_num'].to_i()
  @tag_id = params['tag_id'].to_i()

  @month = @months[@month_num-1]
  @tag = Tag.find_by_id(@tag_id) if (@tag_id != 0)

  @filtered_by_month_and_tag = true if(@tag_id != 0 && @month_num != 0)
  @filtered_tag_only = true if(@tag_id != 0 && @month_num == 0)
  @filtered_month_only = true if(@month_num != 0 && @tag_id == 0)

  @transactions = Transaction.all_sorted_by_timestamp(@sort_by)
  @transactions_amount = Transaction.sum_transactions(@transactions)

  erb(:"transactions/index")
end


post('/transactions/filtered/sorted/:month_num/:tag_id') do
  @months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
              "Aug", "Sep", "Oct", "Nov", "Dec"]

  @tags = Tag.all()
  @user = User.get_user()

  @sort_by = params['sort_by']
  @month_num = params['month_num'].to_i()
  @tag_id = params['tag_id'].to_i()

  @month = @months[@month_num-1]
  @tag = Tag.find_by_id(@tag_id) if (@tag_id != 0)

  @filtered_by_month_and_tag = true if(@tag_id != 0 && @month_num != 0)
  @filtered_tag_only = true if(@tag_id != 0 && @month_num == 0)
  @filtered_month_only = true if(@month_num != 0 && @tag_id == 0)

  @transactions = Transaction.transactions_filtered(@month_num, @tag_id, @sort_by)
  @transactions_amount = Transaction.sum_transactions(@transactions)

  erb(:"transactions/index")

end


get('/transactions/filtered/:month_num') do
  @months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
              "Aug", "Sep", "Oct", "Nov", "Dec"]

  @tags = Tag.all()
  @user = User.get_user()


  @month_num = params['month_num'].to_i()

  @month = @months[@month_num-1]
  @filtered_month_only = true

  @transactions = Transaction.transactions_filtered(@month_num, 0)
  @transactions_amount = Transaction.sum_transactions(@transactions)
  @transaction_view = true
  erb(:"transactions/index")

end
