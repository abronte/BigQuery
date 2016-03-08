
# Module to handle table actions
# https://developers.google.com/bigquery/docs/tables
module BigQuery
  class Client
    module Tables
      ALLOWED_FIELD_TYPES = ['STRING', 'INTEGER', 'FLOAT', 'BOOLEAN', 'RECORD', 'TIMESTAMP']
      ALLOWED_FIELD_MODES = ['NULLABLE', 'REQUIRED', 'REPEATED']

      # Lists the tables
      #
      # @param dataset [String] dataset to look for
      # @return [Hash] json api response
      def tables(dataset = @dataset)
        response = api(
          @client.list_tables(
            @project_id,
            dataset,
            max_results: 9999999 # default is 50
          )
        )
        response['tables'] || []
      end

      # Lists the tables returnning only the tableId
      #
      # @param dataset [String] dataset to look for
      # @return [Hash] json api response
      def tables_formatted(dataset = @dataset)
        tables(dataset).map { |t| t['tableReference']['tableId'] }
      end

      # Returns entire response of table data
      #
      # @param tableId [String] id of the table to look for
      # @param dataset [String] dataset to look for
      # @param options [Hash] hash of optional query parameters (maxResults, startIndex)
      # @return [Hash] json api response
      def table_raw_data(table_id, dataset_id = @dataset, options = {})
        option_parameters = {}
        # I would like to change the option to snake case if there are no users, because I have added this feature
        option_parameters[:max_results] = options[:maxResults] if options[:maxResults]
        option_parameters[:start_index] = options[:startIndex] if options[:startIndex]

        api(
          @client.list_table_data(
            @project_id,
            dataset_id,
            table_id,
            option_parameters
          )
        )
      end

      # Returns all rows of table data
      #
      # @param tableId [String] id of the table to look for
      # @param dataset [String] dataset to look for
      # @param options [Hash] hash of optional query parameters (maxResults, startIndex)
      # @return [Hash] json api response
      def table_data(table_id, dataset_id = @dataset, options = {})
        response = table_raw_data(table_id, dataset_id, options)
        response['rows'] || []
      end

      # insert row into table
      #
      # @param tableId [String] table id to insert into
      # @param opts [Hash] field value hash to be inserted
      # @return [Hash]
      def insert(table_id, opts)
        request = Google::Apis::BigqueryV2::InsertAllTableDataRequest.new
        row = Google::Apis::BigqueryV2::InsertAllTableDataRequest::Row.new
        if opts.class == Array
          request.rows = opts.map{|x| row.json = x; row}
        else
          row.json = opts
          request.rows = [row]
        end

        api(
          @client.insert_all_table_data(
            @project_id,
            @dataset,
            table_id,
            request
          )
        )
      end

      # Creating a new table
      #
      # @param tableId [String] table id to insert into
      # @param schema [Hash] name => opts hash for the schema
      #
      # examples:
      #
      # @bq.create_table('new_table', id: { type: 'INTEGER', mode: 'required' })
      # @bq.create_table('new_table', price: { type: 'FLOAT' })
      def create_table(table_id, schema={})
        table = Google::Apis::BigqueryV2::Table.new(
          table_reference: { project_id: @project_id, dataset_id: @dataset, table_id: table_id },
          schema: { fields: validate_schema(schema) }
        )
        api(
          @client.insert_table(
            @project_id,
            @dataset,
            table
          )
        )
      end

      # Deletes the given table_id
      #
      # @param table_id [String] table id to insert into
      def delete_table(table_id)
        api(
          @client.delete_table(
            @project_id,
            @dataset,
            table_id
          )
        )
      end

      # Patching a exsiting table
      #
      # @param tableId [String] table id to insert into
      # @param schema [Hash] name => opts hash for the schema
      #
      # examples:
      #
      # @bq.patch_table('existing_table', id: { type: 'INTEGER', mode: 'required' }, price: { type: 'FLOAT' })
      # It should be provide entire schema including the difference between the existing schema
      # Otherwise 'BigQuery::Errors::BigQueryError: Provided Schema does not match Table' occur
      def patch_table(table_id, schema={})
        table = Google::Apis::BigqueryV2::Table.new(
          table_reference: { project_id: @project_id, dataset_id: @dataset, table_id: table_id },
          schema: { fields: validate_schema(schema) }
        )
        api(
          @client.patch_table(
            @project_id,
            @dataset,
            table_id,
            table
          )
        )
      end

      # Updating a exsiting table
      #
      # @param tableId [String] table id to insert into
      # @param schema [Hash] name => opts hash for the schema
      #
      # examples:
      #
      # @bq.update_table('existing_table', id: { type: 'INTEGER', mode: 'required' }, price: { type: 'FLOAT' })
      # It should be provide entire schema including the difference between the existing schema
      # Otherwise 'BigQuery::Errors::BigQueryError: Provided Schema does not match Table' occur
      def update_table(table_id, schema={})
        table = Google::Apis::BigqueryV2::Table.new(
          table_reference: { project_id: @project_id, dataset_id: @dataset, table_id: table_id },
          schema: { fields: validate_schema(schema) }
        )
        api(
          @client.update_table(
            @project_id,
            @dataset,
            table_id,
            table
          )
        )
      end

      # Describe the schema of the given tableId
      #
      # @param tableId [String] table id to describe
      # @param dataset [String] dataset to look for
      # @return [Hash] json api response
      def describe_table(table_id, dataset = @dataset)
        api(
          @client.get_table(
            @project_id,
            dataset,
            table_id
          )
        )
      end

      protected

      # Translate given schema to a one understandable by bigquery
      #
      # @param [Hash] schema like { field_nane => { type: 'TYPE', mode: 'MODE' }, ... }
      # @return [Array<Hash>]
      def validate_schema(schema)
        fields = []
        schema.map do |name, options|
          type = (ALLOWED_FIELD_TYPES & [options[:type].to_s]).first
          mode = (ALLOWED_FIELD_MODES & [options[:mode].to_s]).first
          field = { "name" => name.to_s, "type" => type }
          field["mode"] = mode if mode
          if field["type"] == 'RECORD'
            field["fields"] = validate_schema(options[:fields])
          end
          fields << deep_symbolize_keys(field)
        end
        fields
      end
    end
  end
end
