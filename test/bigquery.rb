# encoding: UTF-8
require 'minitest/autorun'
require 'yaml'
require 'big_query'
require 'pry-byebug'

class BigQueryTest < MiniTest::Unit::TestCase
  def setup
    @bq = BigQuery::Client.new(config)
  end

  def config
    return @config if @config
    config_data ||= File.expand_path(File.dirname(__FILE__) + "/../.bigquery_settings.yml")
    @config = YAML.load_file(config_data)
  end

  def test_for_tables
    tables = @bq.tables

    assert_equal tables[0]['kind'], "bigquery#table"
    assert_equal tables[0]['id'], "redbooth-bravo-test:console_test.test"
    assert_equal tables[0]['tableReference']['tableId'], 'test'
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
    result = @bq.create_table('test123', id: { type: 'INTEGER' })

    assert_equal result['kind'], "bigquery#table"
    assert_equal result['tableReference']['tableId'], "test123"
    assert_equal result['schema']['fields'], [{"name"=>"id", "type"=>"INTEGER"}]
  end

  def test_for_delete_table
    if !@bq.tables_formatted.include? 'test123'
      @bq.create_table('test123', id: { type: 'INTEGER' })
    end
    result = @bq.delete_table('test123')

    tables = @bq.tables_formatted

    refute_includes tables, 'test123'
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
end
