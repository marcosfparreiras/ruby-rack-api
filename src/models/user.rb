require 'sequel'
require 'digest/md5'

class User < Sequel::Model
  many_to_one :account
  one_to_one :token

  unrestrict_primary_key

  def before_create
    super
    self.pin = Digest::MD5.hexdigest(pin.to_s)
  end
end
