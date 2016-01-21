module BigQuery
  class Client
    module Datasets

      # Lists the datasets
      #
      # @return [Hash] json api response
      def datasets
        response = api({
          :api_method => @bq.datasets.list,
        })

        response['datasets'] || []
      end

      # Lists the datasets returnning only the tableId
      #
      # @return [Hash] json api response
      def datasets_formatted
        datasets.map { |t| t['datasetReference']['datasetId'] }
      end

      # Creating a new dataset
      #
      # @param datasetId [String] dataset id to insert into
      # @return [Hash] json api response
      #
      # examples:
      #
      # @bq.create_dataset('new_dataset')
      def create_dataset(datasetId)
        api(
          api_method: @bq.datasets.insert,
          body_object: { "datasetReference" => {
                            "datasetId" => datasetId,
                            "projectId" => @project_id,
                          }
                        }
        )
      end

      # Deletes the given datasetId
      #
      # @param datasetId [String] dataset id to insert into
      def delete_dataset(datasetId)
        api(api_method: @bq.datasets.delete,
            parameters: { 'datasetId' => datasetId }
        )
      end
    end
  end
end
