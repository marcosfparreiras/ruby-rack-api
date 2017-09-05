require 'sequel'

class Account < Sequel::Model
  one_to_one :user
  one_to_one :operation

  unrestrict_primary_key
end
