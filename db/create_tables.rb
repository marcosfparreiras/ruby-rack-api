require 'sequel'
require 'pg'

db = Sequel.connect(
  adapter: ENV['DB_ADAPTER'],
  user: ENV['DB_USER'],
  password: ENV['DB_PASS'],
  host: ENV['DB_HOST']
)

db.create_table? :accounts do
  Integer :number, primary_key: true
  Float :current_balance
end

db.create_table? :users do
  Integer :cpf, primary_key: true
  foreign_key :account_number, :accounts
  Integer :pin
  String :name
end

db.create_table? :operations do
  primary_key :id
  foreign_key :account_number, :accounts
  String :type
  Float :amount
end
