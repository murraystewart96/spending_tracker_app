require('pry')
require_relative('../models/merchant')
require_relative('../models/tag')
require_relative('../models/transaction')


Transaction.delete_all()
Merchant.delete_all()
Tag.delete_all()




merchant_info_1 = {
  'name' => 'Tesco'
}

merchant_info_2 = {
  'name' => 'Waitrose'
}

merchant_info_3 = {
  'name' => 'Bank of Scotland'
}

tesco = Merchant.new(merchant_info_1)
tesco.save()
waitrose = Merchant.new(merchant_info_2)
waitrose.save()
bank_of_scotland = Merchant.new(merchant_info_3)
bank_of_scotland.save()


tag_info_1 = {
  'name' => 'groceries'
}

tag_info_2 = {
  'name' => 'banking'
}

groceries = Tag.new(tag_info_1)
groceries.save()

banking = Tag.new(tag_info_2)
banking.save()


transaction_info_1 = {
  'description' => 'weekly shop',
  'amount' => 100,
  'merchant_id' => tesco.id,
  'tag_id' => groceries.id
}

transaction_info_2 = {
  'description' => 'weeklend shop',
  'amount' => 30,
  'merchant_id' => waitrose.id,
  'tag_id' => groceries.id
}

transaction_info_3 = {
  'description' => 'paying back loan',
  'amount' => 300,
  'merchant_id' => bank_of_scotland.id,
  'tag_id' => banking.id
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


binding.pry

nil
