require 'sequel'
# require_relative '../database_connect'

class Operation < Sequel::Model
  many_to_one :account

  unrestrict_primary_key
end
