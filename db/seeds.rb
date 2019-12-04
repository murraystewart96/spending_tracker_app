require('pry')
require_relative('../models/merchant')
require_relative('../models/tag')
require_relative('../models/transaction')
require_relative('../models/user')


Transaction.delete_all()
Merchant.delete_all()
Tag.delete_all()
User.delete_all()



merchant_info_1 = {
  'name' => 'Tesco'
}

merchant_info_2 = {
  'name' => 'Waitrose'
}

merchant_info_3 = {
  'name' => 'Scottish Power'
}

merchant_info_4 = {
  'name' => 'Nandos'
}

merchant_info_5 = {
  'name' => 'Coinbase'
}

merchant_info_6 = {
  'name' => 'Pure Gym'
}


tesco = Merchant.new(merchant_info_1)
tesco.save()

waitrose = Merchant.new(merchant_info_2)
waitrose.save()

scottish_power = Merchant.new(merchant_info_3)
scottish_power.save()

nandos = Merchant.new(merchant_info_4)
nandos.save()

coinbase = Merchant.new(merchant_info_5)
coinbase.save()

pure_gym = Merchant.new(merchant_info_6)
pure_gym.save()


tag_info_1 = {
  'name' => 'Groceries'
}

tag_info_2 = {
  'name' => 'Bills'
}

tag_info_3 = {
  'name' => 'Eating Out'
}

tag_info_4 = {
  'name' => 'Investing'
}

tag_info_5 = {
  'name' => 'Gym'
}

groceries = Tag.new(tag_info_1)
groceries.save()

bills = Tag.new(tag_info_2)
bills.save()

eating_out = Tag.new(tag_info_3)
eating_out.save()

investing = Tag.new(tag_info_4)
investing.save()

gym = Tag.new(tag_info_5)
gym.save()


transaction_info_1 = {
  'description' => 'weekly shop',
  'amount' => 50,
  'merchant_id' => tesco.id,
  'tag_id' => groceries.id
}

transaction_info_2 = {
  'description' => 'weekend shop',
  'amount' => 10,
  'merchant_id' => waitrose.id,
  'tag_id' => groceries.id
}

transaction_info_3 = {
  'description' => 'Buying Bitcoin',
  'amount' => 50,
  'merchant_id' => coinbase.id,
  'tag_id' => investing.id,
}

transaction_info_4 = {
  'description' => 'gym membership',
  'amount' => 10,
  'merchant_id' => pure_gym.id,
  'tag_id' => gym.id,
}
transaction_info_5 = {
  'description' => 'paying bills',
  'amount' => 60,
  'merchant_id' => scottish_power.id,
  'tag_id' => bills.id,
}

transaction_info_6 = {
  'description' => 'Dinner',
  'amount' => 20,
  'merchant_id' => nandos.id,
  'tag_id' => eating_out.id,
}

transaction1 = Transaction.new(transaction_info_1)
transaction1.save()
transaction1.save()
transaction2 = Transaction.new(transaction_info_2)
transaction2.save()
transaction2.save()

transaction3 = Transaction.new(transaction_info_3)
transaction3.save()
transaction3.save()

transaction4 = Transaction.new(transaction_info_4)
transaction4.save()


transaction5 = Transaction.new(transaction_info_5)
transaction5.save()

transaction6 = Transaction.new(transaction_info_6)
transaction6.save()


transactions = [transaction1, transaction2, transaction3,
transaction4, transaction5, transaction6]


for n in 1...70
  rand_num = rand(0..5)
  rand_month = rand(1..12)
  transactions[rand_num].save()

  if (rand_month < 10)
    transactions[rand_num].update_timestamp("2019-0#{rand_month}-01 15:37:08.159519")
  else
    transactions[rand_num].update_timestamp("2019-#{rand_month}-01 15:37:08.159519")
  end
end




user_info = {
  'first_name' => 'Scrooge',
  'last_name' => 'McDuck',
  'balance_warning' => 100
}

user = User.new(user_info)
user.save()
user.first_name = "changed"
user.balance = 300
user.update()

binding.pry

nil
