require_relative 'lib/custom_errors/forbiden'
require_relative 'lib/custom_errors/not_found'
require_relative 'lib/custom_errors/unauthorized'
require_relative 'lib/custom_errors/unprocessable_entity'

class AtmServer
  NAMESPACES = %w(users tokens ping).freeze
  ERROR_CLASSES = [
    ::CustomErrors::Forbiden,
    ::CustomErrors::NotFound,
    ::CustomErrors::Unauthorized,
    ::CustomErrors::UnprocessableEntity
  ].freeze

  def self.call(env)
    process_route(env)
  rescue *ERROR_CLASSES => e
    e.rack_response
  end

  def self.process_route(env)
    env = parse_env(env)
    namespace = env[:paths].shift
    return error_page_not_found unless NAMESPACES.include?(namespace)
    routes(namespace, env)
  end

  def self.routes(namespace, env)
    case namespace
    when 'users'
      users_routes(env)
    when 'tokens'
      tokens_routes(env)
    when 'ping'
      ping_route(env)
    end
  end

  def self.users_routes(env)
    return error_page_not_found unless env[:request_method] == :post
    id = env[:paths][0]
    action = env[:paths][1]

    case action
    when 'authenticate'
      Handlers::User.new(id).authenticate(env[:params])
    end
  end

  def self.tokens_routes(env)
    id = env[:paths][0]
    action = env[:paths][1]

    case env[:request_method]
    when :get
      case action
      when 'operations'
        Handlers::Token.new(id).operations(env[:params])
      end
    when :post
      case action
      when 'withdraw'
        Handlers::Token.new(id).withdraw(env[:params])
      when 'deposit'
        Handlers::Token.new(id).deposit(env[:params])
      end
    when :delete
      Handlers::Token.new(id).signout
    end
  end

  def self.ping_route(env)
    return error_page_not_found unless env[:request_method] == :get
    response = Rack::Response.new
    response.write('pong')
    response.status = 200
    response.finish
  end

  def self.parse_env(env)
    request = Rack::Request.new(env)
    paths = request.env['PATH_INFO'].split('/')
    paths.shift
    {
      paths: paths,
      params: Rack::Utils.parse_nested_query(request.env['QUERY_STRING']),
      request_method: request.env['REQUEST_METHOD'].downcase.to_sym
    }
  end

  def self.error_page_not_found
    response = Rack::Response.new
    response.write('Page no found')
    response.status = 404
    response.finish
    # [404, { 'Content-Type' => 'text/plain' }, ['Page not found']]
  end
end
