module BigQuery
  class Client
    module Tables
      # Lists the tables
      #
      # @param dataset [String] dataset to look for
      # @return [Hash] json api response
      def tables(dataset = @dataset)
        response = api({
          :api_method => @bq.tables.list,
          :parameters => {"datasetId" => dataset}
        })

        response['tables'] || []
      end

      # Lists the tables returnning only the tableId
      #
      # @param dataset [String] dataset to look for
      # @return [Hash] json api response
      def tables_formatted(dataset = @dataset)
        tables(dataset).map {|t| "[#{dataset}.#{t['tableReference']['tableId']}]"}
      end

      # Returns all rows of table data
      #
      # @param tableId [String] id of the table to look for
      # @param dataset [String] dataset to look for
      # @return [Hash] json api response
      def table_data(tableId, dataset = @dataset)
        response = api(api_method: @bq.tabledata.list,
                       parameters: { 'datasetId' => dataset,
                                     'tableId' => tableId })
        response['rows'] || []
      end
    end
  end
end
