# https://cloud.google.com/bigquery/docs/reference/v2/jobs

module BigQuery
  class Client
    module Jobs
      # Fetches a bigquery job by id
      #
      # @param id [Integer] job id to fetch
      # @param options [Hash] bigquery opts accepted
      # @return [Hash] json api response
      def job(id, opts = {})
        api(
          @client.get_job(
            @project_id,
            id,
            deep_symbolize_keys(opts)
          )
        )
      end

      # lists all the jobs
      #
      # @param options [Hash] bigquery opts accepted
      # @return [Hash] json api response
      def jobs(opts = {})
        api(
          @client.list_jobs(
            @project_id,
            deep_symbolize_keys(opts)
          )
        )
      end

      # Gets the results of a given job
      #
      # @param id [Integer] job id to fetch
      # @param options [Hash] bigquery opts accepted
      # @return [Hash] json api response
      def get_query_results(id, opts = {})

        api(
          @client.get_job_query_results(
            @project_id, id, deep_symbolize_keys(opts)
          )
        )
      end

      # Insert a job
      #
      # @param options [Hash] hash of job options
      # @param parameters [Hash] hash of parameters (uploadType, etc.)
      # @param media [Google::APIClient::UploadIO] media upload
      # @return [Hash] json api response
      def insert_job(opts, parameters = {}, media = nil)
        _opts = deep_symbolize_keys(opts)
        job_type = _opts.keys.find { |k| [:copy, :extract, :load, :query].include?(k.to_sym) }
        job_type_configuration = __send__("_#{job_type.to_s}", _opts[job_type])
        job_configuration = Google::Apis::BigqueryV2::JobConfiguration.new(
          job_type.to_sym => job_type_configuration
        )
        job_configuration.dry_run = _opts[:dry_run] if _opts[:dry_run]
        job = Google::Apis::BigqueryV2::Job.new(
          configuration: job_configuration
        )
        api(
          @client.insert_job(
            @project_id,
            job,
            upload_source: media
          )
        )
      end
    end
  end
end
