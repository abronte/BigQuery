module BigQuery
  class Client
    module Insert
      include Jobs
      # Loads file content into a table
      #
      # see https://developers.google.com/bigquery/loading-data-into-bigquery for possible opts
      # @param opts [Hash] field value hash to be inserted
      # @return [Hash]
      def load(opts)
        job_configuration = Google::Apis::BigqueryV2::JobConfiguration.new(
          load: _load(opts.deep_symbolize_keys)
        )
        job_configuration.dry_run = (opts['dryRun'] || opts[:dry_run]) if (opts['dryRun'] || opts[:dry_run])
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
