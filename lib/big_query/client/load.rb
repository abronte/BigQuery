module BigQuery
  class Client
    module Insert
      include Jobs
      # Loading Data From Cloud Datastore
      #
      # see https://cloud.google.com/bigquery/loading-data-cloud-datastore for possible opts
      # @param opts [Hash] field value hash to be inserted
      # @return [Hash]
      def load(opts)
        _opts = deep_symbolize_keys(opts)
        job_configuration = Google::Apis::BigqueryV2::JobConfiguration.new(
          load: _load(_opts)
        )
        job_configuration.dry_run = _opts[:dry_run] if _opts[:dry_run]
        job = Google::Apis::BigqueryV2::Job.new(
          configuration: job_configuration
        )
        @client.insert_job(
          @project_id,
          job
        )
      end
    end
  end
end
