require 'json'
require_relative '../lib/custom_errors/forbiden'
require_relative '../lib/custom_errors/not_found'
require_relative '../lib/custom_errors/unauthorized'
require_relative '../lib/custom_errors/unprocessable_entity'

module Handlers
  class Token
    def initialize(id)
      @token = retrieve_token(id)
      raise ::CustomErrors::NotFound.new unless @token
    end

    def withdraw(params)
      amount = params.delete('amount').to_i
      raise ::CustomErrors::Forbiden unless has_enough_balance?(amount)
      update_account_balance(token_account, -amount)
      create_operation(-amount, 'withdraw')
      RackResponseBuilder.build(200, [{ data: token_account.values }.to_json])
    end

    def deposit(params)
      amount = params.delete('amount').to_i
      account_id = params.delete('account').to_i
      account = retrieve_account(account_id)
      raise ::CustomErrors::Forbiden.new unless account
      update_account_balance(account, +amount)
      create_operation(amount, 'deposit')
      RackResponseBuilder.build(200, [{ data: account.values }.to_json])
    end

    def operations(params)
      from = params.delete('from')
      to = params.delete('to')
      type = params.delete('type')
      values = account_operations(from, to, type)
      RackResponseBuilder.build(200, [{ data: values }.to_json])
    end

    def signout
      token_id = @token.id
      @token.destroy
      RackResponseBuilder.build(200, [{ data: { token_id: token_id } }.to_json])
    end

    private

    def retrieve_token(id)
      ::Token[id]
    end

    def retrieve_account(id)
      ::Account[id.to_i]
    end

    def token_account
      user = ::User[@token.user_cpf]
      ::Account[user.account_number]
    end

    def has_enough_balance?(amount)
      token_account.current_balance >= amount
    end

    def update_account_balance(account, amount)
      account.update(current_balance: account.current_balance + amount)
    end

    def create_operation(amount, type)
      ::Operation.create(
        account_number: token_account.number,
        amount: amount,
        type: type
      )
    end

    def account_operations(from, to, type)
      user = ::User[@token.user_cpf]
      account = ::Account[user.account_number]

      query = Operation.where(account_number: account.number)
      query = from ? query.where { date >= from } : query
      query = to ? query.where { date <= to } : query
      query = type ? query.where(type: type) : query
      query.map(&:values)
    end
  end
end
