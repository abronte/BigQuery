# 0.9.1
* Support optional query parameters to Datasets.list #34
* Fetch all tables #35
* Support optional parameters for Tabledata.list #36
* Add table_raw_data method #37
* Update google-api-client #38
* Support JSON Key file authentication #42
* Fix bug `insert_all_table_data` #43
* Follow the version up of google-api-client #44
* Use pessimitstic version constraint of google-api-client #45

# 0.9.0
* Add wrapper method of `bigquery.tables.patch` and `bigquery.tables.update` #32
* Add wrapper method of `biqquery.datasets.list`, `bigquery.datasets.insert` and `bigquery.datasets.delete` #33

# 0.8.3
* Minor version up google-api-client

# 0.8.2
* Revert google-api-client version up

# 0.8.1
* Tweek condition to reduce the query count #23
* Update google-api-client to `0.9.pre1` #24

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
