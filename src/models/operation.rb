require 'sequel'

class Operation < Sequel::Model
  many_to_one :account

  unrestrict_primary_key
end
