require 'google/api_client'

module BigQuery
  class Client

    attr_accessor :dataset, :project_id

    def initialize(opts = {})
      @client = Google::APIClient.new(
        application_name: 'BigQuery ruby test app',
        application_version: BigQuery::VERSION
      )

      key = Google::APIClient::PKCS12.load_key(File.open(
        opts['key'], mode: 'rb'),
        "notasecret"
      )

      @asserter = Google::APIClient::JWTAsserter.new(
        opts['service_email'],
        "https://www.googleapis.com/auth/bigquery",
        key
      )

      refresh_auth

      @bq = @client.discovered_api("bigquery", "v2")

      @project_id = opts['project_id']
      @dataset = opts['dataset']
    end

    def query(q)
      res = api({
        :api_method => @bq.jobs.query,
        :body_object => { "query" => q, 'timeoutMs' => 90 * 1000}
      })

      if res.has_key? "errors"
        raise BigQueryError, "BigQuery has returned an error :: #{res['errors'].inspect}" 
      else
        res
      end
    end

    def load(opts)
      api({
        :api_method => @bq.jobs.insert,
        :body_object => {
          "configuration" => {
            "load" => opts
          }
        }
      })
    end

    def job(id, opts = {})
      opts['jobId'] = id

      api({
        :api_method => @bq.jobs.get,
        :parameters => opts
      })
    end

    def jobs(opts = {})
      api({
        :api_method => @bq.jobs.list,
        :parameters => opts
      })
    end

    def get_query_results(jobId, opts = {})
      opts['jobId'] = jobId
      api({
        :api_method => @bq.jobs.get_query_results,
        :parameters => opts
      })
    end

    # perform a query synchronously
    # fetch all result rows, even when that takes >1 query
    # invoke /block/ once for each row, passing the row
    def each_row(q, &block)
      current_row = 0
      # repeatedly fetch results, starting from current_row
      # invoke the block on each one, then grab next page if there is one
      # it'll terminate when res has no 'rows' key or when we've done enough rows
      # perform query...
      res = query(q)
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

    def tables(dataset = @dataset)
      api({
        :api_method => @bq.tables.list,
        :parameters => {"datasetId" => dataset}
      })['tables']
    end

    def tables_formatted(dataset = @dataset)
      tables(dataset).map {|t| "[#{dataset}.#{t['tableReference']['tableId']}]"}
    end

    # Returns all rows of table data.
    def table_data(tableId, dataset = @dataset)
      api({
              :api_method => @bq.tabledata.list,
              :parameters => {"datasetId" => dataset, "tableId" => tableId}
          })['rows']
    end

    def refresh_auth
      @client.authorization = @asserter.authorize
    end

    private

    def api(opts)
      if opts[:parameters]
        opts[:parameters] = opts[:parameters].merge({"projectId" => @project_id})
      else
        opts[:parameters] = {"projectId" => @project_id}
      end

      resp = @client.execute(opts)
      data = JSON.parse(resp.body)
      handle_error(data) if is_error?(data)
      data
    end

    # Defines whenever the response is an error or not
    #
    # @param response [Hash] parsed json response
    # @return [Boolean]
    def is_error?(response)
      !response["error"].nil?
    end

    # handles the error and raises an understandable error
    #
    # @param response [Hash] parsed json response
    # @raise [BigQueryError]
    def handle_error(response)
      error = response['error']
      case error['code']
      when 404
        fail NotFound, error['message']
      else
        fail BigQueryError, error['message']
      end
    end
  end

  # BigQuery API errors
  class BigQueryError < StandardError; end
  class NotFound < BigQueryError; end
  class BadDataset < BigQueryError; end
end
