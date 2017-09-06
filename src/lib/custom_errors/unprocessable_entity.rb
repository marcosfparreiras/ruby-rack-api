require_relative '../rack_response_builder'

module CustomErrors
  class UnprocessableEntity < StandardError
    def rack_response
      ::RackResponseBuilder.build(422, ['Unprocessable Entity'])
    end
  end
end
