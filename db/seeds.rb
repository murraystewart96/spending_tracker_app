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

tesco = Merchant.new(merchant_info_1)
tesco.save()


tag_info_1 = {
  'name' => 'groceries'
}

groceries = Tag.new(tag_info_1)
groceries.save()


transaction_info_1 = {
  'description' => 'weekly shop',
  'amount' => 100,
  'merchant_id' => tesco.id,
  'tag_id' => groceries.id
}

transaction1 = Transaction.new(transaction_info_1)
transaction1.save()
transaction1.save()
transaction1.save()

binding.pry

nil
