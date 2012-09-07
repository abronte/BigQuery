# BigQuery

BigQuery is a wrapper around the Google api ruby gem designed to make interacting with BigQuery easier. This gem is very new and doesn't have many features quite yet.

## Install
    
    gem install bigquery

## Authorization

Only service accounts are supported right now. https://developers.google.com/accounts/docs/OAuth2#serviceaccount

## Available methods

* query
* tables
* load
* tables_formatted
* job
* jobs
* refresh_auth

## Example

    require 'bigquery'

    opts = {}
    opts['client_id']     = '1234.apps.googleusercontent.com'
    opts['service_email'] = '1234@developer.gserviceaccount.com'
    opts['key']           = '/path/to/somekeyfile-privatekey.p12'
    opts['project_id']    = '54321'
    opts['dataset']       = 'yourdataset'

    bq = BigQuery.new(opts)

    puts bq.tables

## Troubleshooting

If you're getting an "invalid_grant" error it usually means your system clock is off.

If you're getting unauthorized requested but you've been able to successfully connect before, you need to refresh your auth by running the "refresh_auth" method.

## License

LICENSE:
(The MIT License)

Copyright © 2012 Adam Bronte

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
