require_relative 'lib/user'

class AtmServer
  def self.call(env)
    env = parse_env(env)
    return error_page_not_found unless env[:paths].first == 'user'

    case env[:request_method]
    when :get
      get_routes(env)
    when :post
      post_routes(env)
    else
      error_page_not_found
    end
  end

  def self.get_routes(env)
    [200, {"Content-Type" => "text/plain"}, ['Gets']]
  end

  def self.post_routes(env)
    case env[:paths][1]
    when 'authenticate'
      User.new.authenticate(env[:params])
    when 'deposit'
      User.new.deposit(env[:params])
    when 'withdraw'
      User.new.withdraw(env[:params])
    else
      error_page_not_found
    end
  end

  def self.parse_env(env)
    request = Rack::Request.new(env)
    path = request.env['REQUEST_PATH']
    {
      paths: path.split('/').reject { |p| p.nil? || p.empty? },
      params: Rack::Utils.parse_nested_query(request.env['QUERY_STRING']),
      request_method: request.env['REQUEST_METHOD'].downcase.to_sym
    }
  end

  def self.error_page_not_found
    [404, { 'Content-Type' => 'text/plain' }, ['Page not found']]
  end
end
