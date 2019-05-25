# encoding: UTF-8
require 'minitest/autorun'
require 'yaml'
require 'big_query'
require 'pry-byebug'

module BigQuery
  class Client
    attr_accessor :client
  end
end

class BigQueryTest < MiniTest::Test
  def setup
    @bq = BigQuery::Client.new(config)
    if @bq.tables_formatted.include? 'test'
      @bq.delete_table('test')
    end
    @bq.create_table('test', id: { type: 'INTEGER', mode: 'REQUIRED' }, type: { type: 'STRING', mode: 'NULLABLE' })
  end

  def config
    if defined? @config
      return @config
    else
      config_data ||= File.expand_path(File.dirname(__FILE__) + "/../.bigquery_settings.yml")
      @config = YAML.load_file(config_data)
    end
  end

  def test_faraday_option_config
    assert_equal @bq.client.client.request_options.timeout, 999
  end

  def test_for_tables
    table = @bq.tables.select{|t| t['id'] == "#{config['project_id']}:#{config['dataset']}.test"}.first

    assert_equal table['kind'], "bigquery#table"
    assert_equal table['tableReference']['tableId'], 'test'
  end

  def test_for_tables_formatted
    result = @bq.tables_formatted

    assert_includes result, 'test'
  end

  def test_for_table_raw_data
    result = @bq.table_raw_data('test')

    assert_kind_of Hash, result
    assert_equal result['kind'], "bigquery#tableDataList"
  end

  def test_for_table_data_maxResults
    result = @bq.table_data('test', @bq.dataset, maxResults: 100)

    assert_kind_of Array, result
  end

  def test_for_table_data_startIndex
    # startIndex is Zero-based
    result = @bq.table_data('test', @bq.dataset, maxResults: 100, startIndex: 100)

    assert_kind_of Array, result
  end

  def test_for_create_table
    if @bq.tables_formatted.include? 'test123'
      @bq.delete_table('test123')
    end

    schema = {
      id: { type: 'INTEGER'},
      city: {
        name:"city",
        type:"RECORD",
        mode: "nullable",
        fields: {
          id: {name:"id", type:"INTEGER" },
          name: {name:"name", type:"STRING" },
          country: { name:"country", type:"STRING" },
          time: { name:"time", type:"TIMESTAMP" }
        }
      }
    }

    result = @bq.create_table('test123', schema)

    assert_equal result['kind'], "bigquery#table"
    assert_equal result['tableReference']['tableId'], "test123"
    assert_equal result['schema']['fields'], [
      {"name"=>"id", "type"=>"INTEGER"},
      {
        "name"=>"city",
        "type"=>"RECORD",
        "fields"=>[
          {"name"=>"id", "type"=>"INTEGER"},
          {"name"=>"name", "type"=>"STRING"},
          {"name"=>"country", "type"=>"STRING"},
          {"name"=>"time", "type"=>"TIMESTAMP"}
        ]
      }
    ]
  end

  def test_for_delete_table
    if !@bq.tables_formatted.include? 'test123'
      @bq.create_table('test123', id: { type: 'INTEGER' })
    end
    @bq.delete_table('test123')

    tables = @bq.tables_formatted

    refute_includes tables, 'test123'
  end

  def test_for_patch_table
    schema = {
      id: { type: 'INTEGER', mode: 'REQUIRED' },
      type: { type: 'STRING', mode: 'NULLABLE' },
      date: { type: 'TIMESTAMP' },
      city: {
        name: 'city',
        type: 'RECORD',
        mode: 'nullable',
        fields: {
          id: { name: 'id', type: 'INTEGER' }
        }
      }
    }

    result = @bq.patch_table('test', schema)

    assert_equal result['kind'], "bigquery#table"
    assert_equal result['tableReference']['tableId'], "test"
    assert_equal result['schema']['fields'], [
      { 'name' => 'id', 'type' => 'INTEGER', 'mode' => 'REQUIRED' },
      { 'name' => 'type', 'type' => 'STRING', 'mode' => 'NULLABLE' },
      { 'name' => 'date', 'type' => 'TIMESTAMP' },
      {
        'name' => 'city',
        'type' => 'RECORD',
        'fields' => [
          { 'name' => 'id', 'type' => 'INTEGER' },
        ]
      }
    ]
  end

  def test_for_update_table
    schema = {
      id: { type: 'INTEGER', mode: 'REQUIRED' },
      type: { type: 'STRING', mode: 'NULLABLE' },
      name: { type: 'STRING' }
    }

    result = @bq.update_table('test', schema)

    assert_equal result['kind'], "bigquery#table"
    assert_equal result['tableReference']['tableId'], "test"
    assert_equal result['schema']['fields'], [
      { 'name' => 'id', 'type' => 'INTEGER', 'mode' => 'REQUIRED' },
      { 'name' => 'type', 'type' => 'STRING', 'mode' => 'NULLABLE' },
      { 'name' => 'name', 'type' => 'STRING' }
    ]
  end

  def test_for_describe_table
    result = @bq.describe_table('test')

    assert_equal result['kind'], "bigquery#table"
    assert_equal result['type'], "TABLE"
    assert_equal result['id'], "#{config['project_id']}:#{config['dataset']}.test"
    assert_equal result['tableReference']['tableId'], 'test'
    assert_equal result['schema']['fields'][0]['name'], 'id'
    assert_equal result['schema']['fields'][0]['type'], 'INTEGER'
    assert_equal result['schema']['fields'][0]['mode'], 'REQUIRED'
    assert_equal result['schema']['fields'][1]['name'], 'type'
    assert_equal result['schema']['fields'][1]['type'], 'STRING'
    assert_equal result['schema']['fields'][1]['mode'], 'NULLABLE'
  end

  def test_for_query
    result = @bq.query("SELECT * FROM [#{config['dataset']}.test] LIMIT 1")

    assert_equal result['kind'], "bigquery#queryResponse"
    assert_equal result['jobComplete'], true
  end

  def test_for_query_useQueryCache
    result = @bq.query("SELECT * FROM [#{config['dataset']}.test] LIMIT 1", useQueryCache: true)
    result = @bq.query("SELECT * FROM [#{config['dataset']}.test] LIMIT 1", useQueryCache: true)

    assert_equal result['cacheHit'], true
  end

  def test_for_query_dryRun
    result = @bq.query("SELECT * FROM [#{config['dataset']}.test] LIMIT 1", dryRun: true)

    assert_equal result['jobReference']['jobId'], nil
  end

  def test_for_query_useLegacySql
    result = @bq.query("SELECT * FROM `#{config['dataset']}.test` LIMIT 1", useLegacySql: false)

    assert_equal result['kind'], "bigquery#queryResponse"
    assert_equal result['jobComplete'], true
  end

  def test_for_insert
    result = @bq.insert('test' ,"id" => 123, "type" => "Task")

    assert_equal result['kind'], "bigquery#tableDataInsertAllResponse"
  end

  def test_for_insert_array
    data = [
      {"id" => 123, "type" => "Task"},
      {"id" => 321, "type" => "Other task"}
    ]

    result = @bq.insert('test' , data)

    assert_equal result['kind'], "bigquery#tableDataInsertAllResponse"

    # You can check the results. However, the test is slightly slower
    # sleep 5
    # result = @bq.query("SELECT * FROM [#{config['dataset']}.test]")
    # assert_equal result['totalRows'], "2"
  end

  def test_for_insert_job
    result = @bq.insert_job(query: {query: "SELECT * FROM [#{config['dataset']}.test] LIMIT 1"})

    assert_equal result['kind'], "bigquery#job"
  end

  def test_for_datasets
    dataset = @bq.datasets.select{|t| t['id'] == "#{config['project_id']}:#{config['dataset']}"}.first

    assert_equal dataset['kind'], "bigquery#dataset"
    assert_equal dataset['datasetReference']['datasetId'], config['dataset']
  end

  def test_for_datasets_formatted
    result = @bq.datasets_formatted

    assert_includes result, config['dataset']
  end

  def test_for_create_datasets
    if @bq.datasets_formatted.include? 'test123'
      @bq.delete_dataset('test123')
    end

    result = @bq.create_dataset('test123')

    assert_equal result['kind'], "bigquery#dataset"
    assert_equal result['datasetReference']['datasetId'], 'test123'
  end

  def test_for_delete_datasets
    if !@bq.datasets_formatted.include? 'test123'
      @bq.create_dataset('test123')
    end

    @bq.delete_dataset('test123')

    datasets = @bq.datasets_formatted

    refute_includes datasets, 'test123'
  end
end
