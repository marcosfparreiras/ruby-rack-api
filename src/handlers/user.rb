require 'json'

module Handlers
  class User
    def initialize(id)
      @user = ::User[id.to_i]
    end

    def authenticate(params)
      pin = params['pin'].to_s
      md5_pin = Digest::MD5.hexdigest(pin)
      raw_token = Time.now.to_i.to_s + @user.cpf.to_s
      token = Digest::MD5.hexdigest(raw_token)

      Token.create(id: token, user_cpf: @user.cpf.to_i)

      [200, {"Content-Type" => "text/plain"}, [{token: 'jkj'}.to_json]]
    end

    # def deposit(params)
    #   [200, {"Content-Type" => "text/plain"}, ['deposit']]
    # end

    # def withdraw(params)
    #   [200, {"Content-Type" => "text/plain"}, ['withdraw']]
    # end
  end
end
