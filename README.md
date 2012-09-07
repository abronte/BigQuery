# BigQuery

BigQuery is a wrapper around the Google api ruby gem designed to make interacting with BigQuery easier. This gem is very new and doesn't have many features quite yet.

### Authorization

Only service accounts are supported right now. https://developers.google.com/accounts/docs/OAuth2#serviceaccount

### Available methods

* query
* tables
* load
* tables_formatted
* job
* jobs
* refresh_auth

### Example

    require 'bigquery'

    opts = {}
    opts['client_id']     = '1234.apps.googleusercontent.com'
    opts['service_email'] = '1234@developer.gserviceaccount.com'
    opts['key']           = '/path/to/somekeyfile-privatekey.p12'
    opts['project_id']    = '54321'
    opts['dataset']       = 'yourdataset'

    bq = BigQuery.new(opts)

    puts bq.tables

### Troubleshooting

If you're getting an "invalid_grant" error it usually means your system clock is off.

If you're getting unauthorized requested but you've been able to successfully connect before, you need to refresh your auth by running the "refresh_auth" method.
