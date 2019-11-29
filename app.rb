require('sinatra')
require('sinatra/contrib/all')
require_relative('controllers/transaction_controller')
require_relative('controllers/tag_controller')
require_relative('controllers/merchant_controller')
also_reload('models/*')
also_reload('controllers/*')


get('/') do
  erb(:home)
end
