require('sinatra')
require('sinatra/contrib/all')
require_relative('../models/merchant')
also_reload( '../models/*' )
require('pry')



get('/merchants/new') do
  @merchants = Merchant.all()
  erb(:"merchants/new")
end

post('/merchants') do
  merchant = Merchant.new(params)
  merchant.save()
  redirect(:'transactions/new')
end
