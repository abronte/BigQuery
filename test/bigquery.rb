require 'minitest/autorun'
require 'yaml'
require 'bigquery'

class BigQueryTest < MiniTest::Unit::TestCase
  def setup
    config = File.expand_path(File.dirname(__FILE__) + "/../.bigquery_settings.yml")
    @bq = BigQuery.new(YAML.load_file(config))
  end

  def test_for_tables
    tables = @bq.tables
    
    assert_equal tables[0]['kind'], "bigquery#table"
  end

  def test_for_query
    result = @bq.query("SELECT u FROM [test.test_table] LIMIT 1")

    assert_equal result['kind'], "bigquery#queryResponse"
    assert_equal result['jobComplete'], true
  end

  # def test_timeout_error
  #   sleep(60 * 60)

  #   result = @bq.query("SELECT u FROM [test.test_table] LIMIT 1 asdlfjhasdlkfjhasdlkfklajh")
  #   puts result.inspect
  #   assert_equal result['error'], "bigquery#queryResponse"
  #   assert_equal result['jobComplete'], true
  # end
end