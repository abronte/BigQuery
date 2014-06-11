module BigQuery
  class Client
    module Errors
      # Defines whenever the response is an error or not
      #
      # @param response [Hash] parsed json response
      # @return [Boolean]
      def is_error?(response)
        !response["error"].nil?
      end

      # handles the error and raises an understandable error
      #
      # @param response [Hash] parsed json response
      # @raise [BigQueryError]
      def handle_error(response)
        error = response['error']
        case error['code']
        when 404
          fail NotFound, error['message']
        else
          fail BigQueryError, error['message']
        end
      end
    end
  end
end
