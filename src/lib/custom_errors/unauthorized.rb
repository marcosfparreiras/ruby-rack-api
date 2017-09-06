require_relative '../rack_response_builder'

module CustomErrors
  class Unauthorized < StandardError
    def rack_response
      ::RackResponseBuilder.build(401, ['Unauthorized'])
    end
  end
end
