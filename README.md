# BigQuery

BigQuery is a wrapper around the Google api ruby gem designed to make interacting with BigQuery easier.

## Install

    gem install bigquery

## Authorization

Only service accounts are supported right now. https://developers.google.com/accounts/docs/OAuth2#serviceaccount

## Available methods

* query
* tables
* datasets
* load
* tables_formatted
* job
* jobs
* insert_job
* refresh_auth

## Example

    require 'big_query'

    opts = {}
    opts['client_id']     = '1234.apps.googleusercontent.com'
    opts['service_email'] = '1234@developer.gserviceaccount.com'
    opts['key']           = '/path/to/somekeyfile-privatekey.p12'
    opts['project_id']    = '54321'
    opts['dataset']       = 'yourdataset'

    bq = BigQuery::Client.new(opts)

    puts bq.tables

## Tables

List tables in dataset

    bq.tables

List table names

    bq.tables_formatted

Fetch table data

    bq.table_data('table_name')

Delete exiting table

    bq.delete_table('test123')

Create table. First param is the table name second one is the table schema defined with the following format

    {
        field_name: {
            type: 'TYPE_VALUE BETWEEN (STRING, INTEGER, FLOAT, BOOLEAN, RECORD, TIMESTAMP)',
            mode: 'MODE_VALUE BETWEEN (NULLABLE, REQUIRED, REPEATED)'
        },
        other_field_name: { ... }
    }


As this example defines

    table_name = 'test123'
    table_schema = { id: { type: 'INTEGER' },
                     name: { type: 'STRING' } }
    bq.create_table(table_name, table_schema)

Describe table schema

    bq.describe_table('table_name')

## Datasets

List datasets in dataset

    bq.datasets

List dataset names

    bq.datasets_formatted

Delete exiting dataset

    bq.delete_dataset('test123')

Create dataset. First param is the dataset name

    bq.create_dataset('test123')

## Querying

    bq.query("SELECT * FROM [#{config['dataset']}.table_name] LIMIT 1")

## Inserting

Insert a single row

    bq.insert('table_name', 'id' => 123, 'type' => 'Task')

Batch insert an array of rows. [See bigquery docs for limitations.](https://cloud.google.com/bigquery/streaming-data-into-bigquery#quota)

    data = [{'id' => 123, 'type' => 'Foo'}, {'id' => 321, 'type' => 'Bar'}]
    bq.insert('table_name', data)

# Patching

Patching a exiting table

    bq.patch_table('test', 'id' => 123, 'type' => 'Task', 'name' => 'Task1')

Tables: patch [See bigquery docs for details.](https://cloud.google.com/bigquery/docs/reference/v2/tables/patch)

# Updating

Updating a exiting table

    bq.update_table('test', 'id' => 123, 'type' => 'Task', 'name' => 'Task1')

Tables: update [See bigquery docs for details.](https://cloud.google.com/bigquery/docs/reference/v2/tables/update)

## Keys

To get the keys you need to have a:

* google API project (link)[https://console.developers.google.com/project]
* bigquery activated (link)[https://bigquery.cloud.google.com]
* create a bigquery dataset in the project (link)[https://bigquery.cloud.google.com]

1- Goto your project google api access

https://code.google.com/apis/console/b/0/?noredirect&pli=1#project:YOUR_PROJECT_ID:access

2- Create a new client-ID for service_account
3- Download de key file

Now you have everything:

* client_id: API access client-ID
* service_email: API access Email address
* key: API access key file path
* project_id: your google API project id
* dataset: your big query dataset name

## Troubleshooting

If you're getting an "invalid_grant" error it usually means your system clock is off.

If you're getting unauthorized requested but you've been able to successfully connect before, you need to refresh your auth by running the "refresh_auth" method.

## How to run test

Before run test, you must create file named `.bigquery_settings.yml` on root of this repository. `.bigquery_settings.yml` must include following infomation.

```yaml
client_id:     '1234.apps.googleusercontent.com'
service_email: '1234@developer.gserviceaccount.com'
key:           '/path/to/somekeyfile-privatekey.p12'
project_id:    '54321'
dataset:       'yourdataset'
faraday_option:
  timeout: 999
```

Then run tests via rake.

```
$ bundle install && bundle exec rake test
```

## Contributing

Fork and submit a pull request and make sure you add a test for any feature you add.

## License

LICENSE:

(The MIT License)

Copyright © 2012 Adam Bronte

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
