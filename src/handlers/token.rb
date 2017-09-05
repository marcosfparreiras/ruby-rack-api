require 'json'

module Handlers
  class Token
    def initialize(id)
      @token = ::Token[id.to_i]
    end

    def operations(params)
    end

    def withdraw(params)
    end

    def deposit(params)
    end
  end
end
