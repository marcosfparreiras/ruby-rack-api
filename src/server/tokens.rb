module Server
  class Tokens
    def self.route(env)
      id = env[:paths][0]
      action = env[:paths][1]

      case env[:request_method]
      when :get
        route_get(id, action, env)
      when :post
        route_post(id, action, env)
      when :delete
        route_delete(id, action, env)
      else
        raise ::CustomErrors::NotFound
      end
    end

    def self.route_get(id, action, env)
      raise ::CustomErrors::NotFound unless action == 'operations'
      Handlers::Token.new(id).operations(env[:params])
    end

    def self.route_post(id, action, env)
      case action
      when 'withdraw'
        Handlers::Token.new(id).withdraw(env[:params])
      when 'deposit'
        Handlers::Token.new(id).deposit(env[:params])
      else
        raise ::CustomErrors::NotFound
      end
    end

    def self.route_delete(id, action, env)
      raise ::CustomErrors::NotFound if action
      Handlers::Token.new(id).signout
    end
  end
end
