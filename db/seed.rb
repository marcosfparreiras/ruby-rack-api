require_relative '../src/lib/database_connection'
DatabaseConnection.create_tables

require_relative '../src/models/operation'
require_relative '../src/models/user'
require_relative '../src/models/account'
require_relative '../src/models/token'
require_relative '../src/handlers/user'

db = DatabaseConnection.connect
db.drop_table?(:tokens, :operations, :users, :accounts)
DatabaseConnection.create_tables

acc1 = Account.create(number: 111)
acc2 = Account.create(number: 222)

u1 = User.create(cpf: 10101, name: 'User1', account_number: acc1.number, pin: 111)
u2 = User.create(cpf: 12312, name: 'User2', account_number: acc2.number, pin: 222)

Operation.create(account_number: acc2.number, type: 'deposit', amount: 100, date: Date.new(2017, 1, 1))
Operation.create(account_number: acc2.number, type: 'deposit', amount: 200, date: Date.new(2017, 3, 10))
Operation.create(account_number: acc2.number, type: 'withdraw', amount: -20, date: Date.new(2017, 4, 11))

Operation.create(account_number: acc1.number, type: 'deposit', amount: 200, date: Date.new(2017, 1, 1))
Operation.create(account_number: acc1.number, type: 'withdraw', amount: -20, date: Date.new(2017, 1, 4))
Operation.create(account_number: acc1.number, type: 'withdraw', amount: -10, date: Date.new(2017, 1, 12))
