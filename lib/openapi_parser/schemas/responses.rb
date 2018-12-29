# TODO: support extended property

module OpenAPIParser::Schemas
  class Responses < Base
    # @!attribute [r] default
    #   @return [Response, Reference, nil] default response object
    openapi_attr_object :default, Response, reference: true

    # @!attribute [r] response
    #   @return [Hash{String => Response, Reference}, nil] response object indexed by status code. see: https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.2.md#patterned-fields-1
    openapi_attr_hash_body_objects 'response', Response, reject_keys: [:default], allow_reference: true, allow_data_type: false

    # validate params data by definition
    # find response object by status_code and content_type
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.2.md#patterned-fields-1
    # @param [Integer] status_code
    # @param [String] content_type
    # @param [Hash] params
    def validate_response_body(status_code, content_type, params)
      return nil unless response

      res = response[status_code.to_s]
      return res.validate_parameter(content_type, params) if res

      wild_card = status_code_to_wild_card(status_code)
      res = response[wild_card]
      return res.validate_parameter(content_type, params) if res

      default&.validate_parameter(content_type, params)
    end

    private

      # parse 400 -> 4xx
      # OpenAPI3 allow 1xx, 2xx, 3xx... only, don't allow 41x
      # @param [Integer] status_code
      def status_code_to_wild_card(status_code)
        top = status_code / 100
        "#{top}XX"
      end
  end
end