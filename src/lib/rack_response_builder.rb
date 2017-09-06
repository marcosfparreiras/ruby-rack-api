class RackResponseBuilder
  class << self
    def build(status, body)
      response = Rack::Response.new
      response.body = body
      response.status = status
      response.finish
    end
  end
end
