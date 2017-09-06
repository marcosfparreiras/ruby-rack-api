require_relative '../rack_response_builder'

module CustomErrors
  class NotFound < StandardError
    def rack_response
      ::RackResponseBuilder.build(404, ['Not Found'])
    end
  end
end
