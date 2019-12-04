require('sinatra')
require('sinatra/contrib/all')
require_relative('../models/tag')
also_reload( '../models/*' )
require('pry')


get('/tags/new') do
  @tags = Tag.all()
  erb(:"tags/new")
end

post('/tags') do
  tag = Tag.new(params)
  tag.save()
  @tags = Tag.all()
  erb(:'tags/new')
end
