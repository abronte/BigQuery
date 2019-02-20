require 'big_query/client/errors'
require 'big_query/client/query'
require 'big_query/client/jobs'
require 'big_query/client/tables'
require 'big_query/client/datasets'
require 'big_query/client/load'
require 'big_query/client/hashable'
require 'big_query/client/options'
require 'big_query/client/response'
require 'big_query/client/job_types'

module BigQuery
  class Client
    include BigQuery::Client::Errors
    include BigQuery::Client::Query
    include BigQuery::Client::Jobs
    include BigQuery::Client::Tables
    include BigQuery::Client::Datasets
    include BigQuery::Client::Insert
    include BigQuery::Client::Hashable
    include BigQuery::Client::Options
    include BigQuery::Client::Response
    include BigQuery::Client::JobTypes

    attr_accessor :dataset, :project_id

    def initialize(opts = {})
      # for debug
      # Google::Apis.logger.level = Logger::DEBUG

      @client = Google::Apis::BigqueryV2::BigqueryService.new

      @client.client_options.application_name = 'BigQuery ruby app'
      @client.client_options.application_version = BigQuery::VERSION

      # Memo:
      # The google-api-client 0.9 is HTTP Client no longer in Faraday
      # We accepts the options for backward compatibility
      # (HTTP Client is replaced in the near future HTTP::Client...)
      # https://github.com/google/google-api-ruby-client/issues/336#issuecomment-179400592
      if opts['faraday_option'].is_a?(Hash)
        @client.request_options.timeout_sec = opts['faraday_option']['timeout']
        @client.request_options.open_timeout_sec = opts['faraday_option']['open_timeout']
      # We accept the request_option instead of faraday_option
      elsif opts['request_option'].is_a?(Hash)
        @client.request_options.timeout_sec = opts['request_option']['timeout_sec']
        @client.request_options.open_timeout_sec = opts['request_option']['open_timeout_sec']
      end

      scope = 'https://www.googleapis.com/auth/bigquery'
      if opts['json_key'].is_a?(String) && !opts['json_key'].empty?
        if File.exist?(opts['json_key'])
          auth = File.open(opts['json_key']) do |f|
            Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: f, scope: scope)
          end
        else
          key = StringIO.new(opts['json_key'])
          auth = Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: key, scope: scope)
        end
      else
        begin
          key = Google::APIClient::KeyUtils.load_from_pkcs12(opts['key'], 'notasecret')
        rescue ArgumentError
          key = Google::APIClient::KeyUtils.load_from_pem(opts['key'], 'notasecret')
        end
        auth = Signet::OAuth2::Client.new(
            token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
            audience: 'https://accounts.google.com/o/oauth2/token',
            scope: scope,
            issuer: opts['service_email'],
            signing_key: key)
      end

      @client.authorization = auth

      refresh_auth

      @project_id = opts['project_id']
      @dataset = opts['dataset']
    end

    def refresh_auth
      @client.authorization.fetch_access_token!
    end

    private

    def api(resp)
      resp = nil if resp == ''
      data = deep_stringify_keys(resp.to_h)
      handle_error(data) if data && is_error?(data)
      data
    end
  end
end
