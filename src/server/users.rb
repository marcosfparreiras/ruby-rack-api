module Server
  class Users
    def self.route(env)
      raise ::CustomErrors::NotFound unless env[:request_method] == :post
      id = env[:paths][0]
      action = env[:paths][1]

      case action
      when 'authenticate'
        Handlers::User.new(id).authenticate(env[:params])
      else
        raise ::CustomErrors::NotFound
      end
    end
  end
end
