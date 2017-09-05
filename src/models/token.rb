require 'sequel'

class Token < Sequel::Model
  many_to_one :user

  unrestrict_primary_key
end
