require 'big_query/client/errors'
require 'big_query/client/query'
require 'big_query/client/jobs'
require 'big_query/client/tables'
require 'big_query/client/load'

module BigQuery
  class Client
    include BigQuery::Client::Errors
    include BigQuery::Client::Query
    include BigQuery::Client::Jobs
    include BigQuery::Client::Tables
    include BigQuery::Client::Insert

    attr_accessor :dataset, :project_id

    def initialize(opts = {})
      @client = Google::APIClient.new(
        application_name: 'BigQuery ruby app',
        application_version: BigQuery::VERSION,
        faraday_option: opts['faraday_option']
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

    def refresh_auth
      @client.authorization = @asserter.authorize
    end

    private

    # Performs the api calls with the given params adding the defined project and
    # dataset params if not defined
    #
    # @param opts [Hash] options for the api call
    # @return [Hash] json response
    def api(opts)
      if opts[:parameters]
        opts[:parameters] = opts[:parameters].merge({"projectId" => @project_id})
      else
        opts[:parameters] = {"projectId" => @project_id}
      end

      resp = @client.execute(opts)
      data = parse_body(resp)
      handle_error(data) if data && is_error?(data)
      data
    end

    # Parses json body if present and is a json formatted
    #
    # @param resp [Faraday::Response] response object
    # @return [Hash]
    def parse_body(resp)
      return nil unless resp.body && !resp.body.empty?
      JSON.parse(resp.body)
    end
  end
end
