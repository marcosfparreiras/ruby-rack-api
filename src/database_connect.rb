require 'sequel'

Sequel.connect(
  adapter: ENV['DB_ADAPTER'],
  user: ENV['DB_USER'],
  password: ENV['DB_PASS'],
  host: ENV['DB_HOST']
)
