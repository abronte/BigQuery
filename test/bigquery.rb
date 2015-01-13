# encoding: UTF-8
require 'minitest/autorun'
require 'yaml'
require 'big_query'
require 'pry-byebug'

class BigQueryTest < MiniTest::Unit::TestCase
  def setup
    @bq = BigQuery::Client.new(config)
    if @bq.tables_formatted.include? 'test'
      @bq.delete_table('test')
    end
    result = @bq.create_table('test', id: { type: 'INTEGER', mode: 'REQUIRED' }, type: { type: 'STRING', mode: 'NULLABLE' })
  end

  def config
    return @config if @config
    config_data ||= File.expand_path(File.dirname(__FILE__) + "/../.bigquery_settings.yml")
    @config = YAML.load_file(config_data)
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

  def test_for_table_data
    result = @bq.table_data('test')

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
    result = @bq.delete_table('test123')

    tables = @bq.tables_formatted

    refute_includes tables, 'test123'
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
  end

  def test_for_insert_job
    result = @bq.insert_job(query: {query: "SELECT * FROM [#{config['dataset']}.test] LIMIT 1"})

    assert_equal result['kind'], "bigquery#job"
  end
end
