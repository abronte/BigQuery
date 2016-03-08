require 'big_query/client/errors'
require 'big_query/client/query'
require 'big_query/client/jobs'
require 'big_query/client/tables'
require 'big_query/client/datasets'
require 'big_query/client/load'

module BigQuery
  class Client
    include BigQuery::Client::Errors
    include BigQuery::Client::Query
    include BigQuery::Client::Jobs
    include BigQuery::Client::Tables
    include BigQuery::Client::Datasets
    include BigQuery::Client::Insert

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
      # We accept the request_option instead of faraday_options
      elsif opts['request_option'].is_a?(Hash)
        @client.request_options.timeout_sec = opts['request_option']['timeout_sec']
        @client.request_options.open_timeout_sec = opts['request_option']['open_timeout_sec']
      end

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

      @project_id = opts['project_id']
      @dataset = opts['dataset']
    end

    def refresh_auth
      @client.authorization.fetch_access_token!
    end

    private

    def normalize_schema(schema)
      schema.map do |s|
        if s.respond_to?(:[])
          f = {
            name: (s[:name] || s["name"]),
            type: (s[:type] || s["type"])
          }
          f[:mode] = (s[:mode] || s["mode"]) if (s[:mode] || s["mode"])
          if (sub_fields = (s[:fields] || s["fields"]))
            f[:fields] = normalize_schema(sub_fields)
          end
        else
          f = {
            name: s.name,
            type: s.type
          }
          f[:mode] = f.mode if f.mode
          if (sub_fields = f.fields)
            f[:fields] = normalize_schema(sub_fields)
          end
        end
        f
      end
    end
  end
end
