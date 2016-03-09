require 'json'
require 'google/apis/bigquery_v2'
require 'google/api_client/auth/key_utils'
require 'big_query/version'
require 'big_query/errors'
require 'big_query/client'

module BigQuery
  include BigQuery::Errors
end
