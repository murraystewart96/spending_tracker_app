require('sinatra')
require('sinatra/contrib/all')
require_relative('../models/user')
also_reload( '../models/*' )
require('pry')

get('/users/add-funds') do
  @user = User.get_user()
  erb(:"users/update")
end

post('/users') do
  @user = User.get_user()
  @user.balance += params['amount'].to_f()
  @user.update()
  redirect(:"users/add-funds")
end
