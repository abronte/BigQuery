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
    attr_reader :client

    def initialize(opts = {})
      @client = Google::APIClient.new(
        application_name: 'BigQuery ruby app',
        application_version: BigQuery::VERSION,
        faraday_option: opts['faraday_option']
      )

      begin
        key = Google::APIClient::KeyUtils.load_from_pkcs12(opts['key'], 'notasecret')
      rescue ArgumentError
        key = Google::APIClient::KeyUtils.load_from_pem(opts['key'], 'notasecret')
      end

      @client.authorization = Signet::OAuth2::Client.new(
        token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
        audience: 'https://accounts.google.com/o/oauth2/token',
        scope: 'https://www.googleapis.com/auth/bigquery',
        issuer: opts['service_email'],
        signing_key: key)

      refresh_auth

      @bq = @client.discovered_api("bigquery", "v2")

      @project_id = opts['project_id']
      @dataset = opts['dataset']
    end

    def refresh_auth
      @client.authorization.fetch_access_token!
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
