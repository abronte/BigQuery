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
end