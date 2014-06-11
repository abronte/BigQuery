require 'big_query/client/errors'
require 'big_query/client/query'
require 'big_query/client/jobs'
require 'big_query/client/tables'

module BigQuery
  class Client
    include BigQuery::Client::Errors
    include BigQuery::Client::Query
    include BigQuery::Client::Jobs
    include BigQuery::Client::Tables

    attr_accessor :dataset, :project_id

    def initialize(opts = {})
      @client = Google::APIClient.new(
        application_name: 'BigQuery ruby app',
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

    def load(opts)
      api(
        api_method: @bq.jobs.insert,
        body_object: {
          'configuration' => {
            'load' => opts
          }
        }
      )
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
  end
end
