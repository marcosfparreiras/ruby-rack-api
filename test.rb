require_relative 'src/lib/database_connection'
DatabaseConnection.create_tables

require_relative 'src/models/operation'
require_relative 'src/models/user'
require_relative 'src/models/account'
require_relative 'src/models/token'
require_relative 'src/handlers/user'

db = DatabaseConnection.connect
db.drop_table?(:tokens, :operations, :users, :accounts)
DatabaseConnection.create_tables

acc1 = Account.create(number: 111)
acc2 = Account.create(number: 222)

u1 = User.create(cpf: 10101, account_number: acc1.number)
u1 = User.create(cpf: 10101, name: 'User1', account_number: acc1.number, pin: 111)
u2 = User.create(cpf: 12312, name: 'User2', account_number: acc2.number)

db.create_table? :tests do
  primary_key :id
  Integer :bla, allow_null: false
end
