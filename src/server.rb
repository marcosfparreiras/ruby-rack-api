require_relative 'lib/custom_errors/forbiden'
require_relative 'lib/custom_errors/not_found'
require_relative 'lib/custom_errors/unauthorized'
require_relative 'lib/custom_errors/unprocessable_entity'
require_relative 'server/users'
require_relative 'server/tokens'

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
    raise ::CustomErrors::NotFound unless NAMESPACES.include?(namespace)
    route_by_namespace(namespace, env)
  end

  def self.route_by_namespace(namespace, env)
    case namespace
    when 'users'
      Server::Users.route(env)
    when 'tokens'
      Server::Tokens.route(env)
    when 'ping'
      ping_route(env)
    end
  end

  def self.ping_route(env)
    raise ::CustomErrors::NotFound unless env[:request_method] == :get
    [200, {}, ['pong']]
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
end
