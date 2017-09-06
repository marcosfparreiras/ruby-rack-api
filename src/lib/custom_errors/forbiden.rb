require_relative '../rack_response_builder'

module CustomErrors
  class Forbiden < StandardError
    def rack_response
      ::RackResponseBuilder.build(403, ['Forbiden'])
    end
  end
end
