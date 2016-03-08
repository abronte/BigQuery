module BigQuery
  class Client
    module Query
      # Performs the given query in the bigquery api
      #
      # @param given_query [String] query to perform
      # @param options [Hash] query options
      # @option options [Integer] timeout or timeoutMs (90 * 1000) timeout in miliseconds
      # @option options [Boolean] dryRun Don't actually run this job
      # @option options [Integer] maxResults The maximum number of rows of data to return per page of results.
      # @option options [Boolean] useQueryCache Whether to look for the result in the query cache.
      # @return [Hash] json api response
      # @see https://cloud.google.com/bigquery/docs/reference/v2/jobs/query
      def query(given_query, options={})
        query_request = Google::Apis::BigqueryV2::QueryRequest.new(
          query: given_query,
        )
        query_request.timeout_ms       = options[:timeout] || options[:timeoutMs] || 90 * 1000
        query_request.max_results      = options[:maxResults] if options[:maxResults]
        query_request.dry_run          = options[:dryRun] if options.has_key?(:dryRun)
        query_request.use_query_cache  = options[:useQueryCache] if options.has_key?(:useQueryCache)

        response = @client.query_job(
          @project_id,
          query_request
        )

        response.to_h.deep_stringify_keys
      end

      # perform a query synchronously
      # fetch all result rows, even when that takes >1 query
      # invoke /block/ once for each row, passing the row
      #
      # @param q [String] query to be executed
      # @param options [Hash] query options
      # @option options [Integer] timeout (90 * 1000) timeout in miliseconds
      def each_row(q, options = {}, &block)
        current_row = 0
        # repeatedly fetch results, starting from current_row
        # invoke the block on each one, then grab next page if there is one
        # it'll terminate when res has no 'rows' key or when we've done enough rows
        # perform query...
        res = query(q, options)
        job_id = res['jobReference']['jobId']
        # call the block on the first page of results
        if( res && res['rows'] )
          res['rows'].each(&block)
          current_row += res['rows'].size
        end
        # keep grabbing pages from the API and calling the block on each row
        while( current_row < res['totalRows'].to_i && ( res = get_query_results(job_id, :startIndex => current_row) ) && res['rows'] ) do
          res['rows'].each(&block)
          current_row += res['rows'].size
        end
      end
    end
  end
end
