module BigQuery
  class Client
    module Insert
      # Loads file content into a table
      #
      # see https://developers.google.com/bigquery/loading-data-into-bigquery for possible opts
      # @param opts [Hash] field value hash to be inserted
      # @return [Hash]
      def load(opts)
        api(
          api_method: @bq.jobs.insert,
          body_object: {
            'configuration' => {
              'load' => opts
            }
          }
        )
      end
    end
  end
end
