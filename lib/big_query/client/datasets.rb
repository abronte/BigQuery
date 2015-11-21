
# Module to handle dataset actions
# https://developers.google.com/bigquery/docs/datasets
module BigQuery
  class Client
    module Datasets

      # Creating a new dataset
      #
      # @param datasetId [String] dataset id to create
      #
      # examples:
      #
      # @bq.create_dataset('new_dataset')
      def create_dataset(datasetId)
        api(
          api_method: @bq.datasets.insert,
          parameters: { "projectId" => @project_id },
          body_object: { "datasetReference" => {
                            "projectId" => @project_id,
                            "datasetId" => datasetId
                          }                        
                       }
        )
      end

    end
  end
end
