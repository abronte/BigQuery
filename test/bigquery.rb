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
  end

  def test_for_query
    result = @bq.query("SELECT * FROM [#{config['dataset']}.test] LIMIT 1")

    assert_equal result['kind'], "bigquery#queryResponse"
    assert_equal result['jobComplete'], true
  end

  def test_for_load
    result = @bq.insert_all('test' ,"id" => 123, "type" => "Task")

    assert_equal result['kind'], "bigquery#tableDataInsertAllResponse"
  end
  # def test_timeout_error
  #   sleep(60 * 60)

  #   result = @bq.query("SELECT u FROM [test.test_table] LIMIT 1 asdlfjhasdlkfjhasdlkfklajh")
  #   puts result.inspect
  #   assert_equal result['error'], "bigquery#queryResponse"
  #   assert_equal result['jobComplete'], true
  # end
end
