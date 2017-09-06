require 'json'
require_relative '../lib/custom_errors/forbiden'
require_relative '../lib/custom_errors/not_found'
require_relative '../lib/custom_errors/unauthorized'
require_relative '../lib/custom_errors/unprocessable_entity'

module Handlers
  class User
    def initialize(id)
      @user = retrieve_user(id)
      raise ::CustomErrors::NotFound.new unless @user
    end

    def authenticate(params)
      pin = params.delete('pin')
      authenticate_user(pin)
      token = create_token
      [201, { 'Content-Type' => 'text/plain' }, [{ data: { token_id: token.id }}.to_json]]
    end

    private

    def retrieve_user(id)
      ::User[id.to_i]
    end

    def authenticate_user(pin)
      md5_pin = Digest::MD5.hexdigest(pin)
      raise ::CustomErrors::Unauthorized.new unless @user.pin == md5_pin
    end

    def create_token
      raw_token = Time.now.to_i.to_s + @user.cpf.to_s
      token_number = Digest::MD5.hexdigest(raw_token)
      ::Token.create(id: token_number, user_cpf: @user.cpf.to_i)
    end
  end
end
