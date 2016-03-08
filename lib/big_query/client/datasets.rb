module BigQuery
  class Client
    module Datasets

      # Lists the datasets
      #
      # @return [Hash] json api response
      def datasets(parameters = {})
        response = @client. list_datasets(
          @project_id,
          parameters
        )

        response.datasets || []
      end

      # Lists the datasets returnning only the tableId
      #
      # @return [Hash] json api response
      def datasets_formatted(parameters = {})
        datasets(parameters).map { |t| t.dataset_reference.dataset_id }
      end

      # Creating a new dataset
      #
      # @param datasetId [String] dataset id to insert into
      # @return [Hash] json api response
      #
      # examples:
      #
      # @bq.create_dataset('new_dataset')
      def create_dataset(dataset_id)
        dataset = Google::Apis::BigqueryV2::Dataset.new(
          dataset_reference:  { project_id: @project_id, dataset_id: dataset_id }
        )
        @client.insert_dataset(
          @project_id,
          dataset
        )
      end

      # Deletes the given datasetId
      #
      # @param datasetId [String] dataset id to insert into
      def delete_dataset(dataset_id)
        @client.delete_dataset(
          @project_id,
          dataset_id
        )
      end
    end
  end
end
