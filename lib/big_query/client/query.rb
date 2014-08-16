module BigQuery
  class Client
    module Query
      # Performs the given query in the bigquery api
      #
      # @param given_query [String] query to perform
      # @param options [Hash] query options
      # @option options [Integer] timeout (90 * 1000) timeout in miliseconds
      # @return [Hash] json api response
      def query(given_query, options={})
        timeout = options.fetch(:timeout, 90 * 1000)
        response = api(
          api_method: @bq.jobs.query,
          body_object: { 'query' => given_query,
                         'timeoutMs' => timeout}
        )

        response
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
        while(( res = get_query_results(job_id, :startIndex => current_row) ) && res['rows'] && current_row < res['totalRows'].to_i ) do
          res['rows'].each(&block)
          current_row += res['rows'].size
        end
      end
    end
  end
end
