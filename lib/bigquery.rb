require 'google/api_client'

class BigQuery

  attr_accessor :dataset, :project_id

  def initialize(opts = {})
    @client = Google::APIClient.new

    @client.authorization.client_id = opts['client_id']
    @client.authorization.client_secret = opts['client_secret']
    @client.authorization.refresh_token = opts['refresh_token']

    @client.authorization.fetch_access_token!
    @bq = @client.discovered_api("bigquery", "v2")

    @project_id = opts['project_id']
    @dataset = opts['dataset']
  end

  def query(q)
    api({
      :api_method => @bq.jobs.query,
      :body_object => { "query" => q, 'timeoutMs' => 90 * 1000}
    })
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

  def tables(dataset = @dataset)
    api({
      :api_method => @bq.tables.list,
      :parameters => {"datasetId" => dataset}
    })['tables']
  end

  def tables_formatted(dataset = @dataset)
    tables(dataset).map {|t| "[#{dataset}.#{t['tableReference']['tableId']}]"}
  end

  private

  def api(opts)
    if opts[:parameters]
      opts[:parameters] = opts[:parameters].merge({"projectId" => @project_id})
    else
      opts[:parameters] = {"projectId" => @project_id}
    end

    resp = @client.execute(opts)
    JSON.parse(resp.body)
  end
end
