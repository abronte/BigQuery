# BigQuery API errors
module BigQuery::Errors
  class BigQueryError < StandardError; end
  class NotFound < BigQueryError; end
  class BadDataset < BigQueryError; end
end
