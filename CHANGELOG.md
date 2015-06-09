# 0.8.0
* Allow media and parameters when inserting jobs #20
* Add query options such as useQueryCache, dryRun, maxResults #22

# 0.7.0
* Adds support for passing string as key #18
* Switch to Signet::OAuth2::Client for authorization #17

# 0.6.1
* Include insert module #16

# 0.4.0
* Added BigQuery::Client#insert_job. https://cloud.google.com/bigquery/docs/reference/v2/jobs/insert

# 0.3.0
* Added support to insert to allow for array of rows
* Locked the google-api-client gem to ~> 0.7.X
* Added a possible work around to #13
