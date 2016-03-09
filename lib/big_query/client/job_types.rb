module BigQuery
  class Client
    module JobTypes

      def _copy(opts)
        _opts = opts.dup
        if (_opts[:source_tables])
          _opts[:source_tables] = _opts[:source_tables].dup.map { |source_table| Google::Apis::BigqueryV2::TableReference.new(source_table) }
        else
          _opts[:source_table] = Google::Apis::BigqueryV2::TableReference.new(_opts[:source_table])
        end
        _opts[:destination_table] = Google::Apis::BigqueryV2::TableReference.new(_opts[:destination_table])

        Google::Apis::BigqueryV2::JobConfigurationCopy.new(
          _opts
        )
      end

      def _extract(opts)
        _opts = opts.dup
        _opts[:source_table] = Google::Apis::BigqueryV2::TableReference.new(_opts[:source_table])
        Google::Apis::BigqueryV2::JobConfigurationExtract.new(
          _opts
        )
      end

      def _load(opts)
        _opts = opts.dup
        _opts[:destination_table] = Google::Apis::BigqueryV2::TableReference.new(_opts[:destination_table])
        _opts[:schema] = Google::Apis::BigqueryV2::TableSchema.new({ fields: _opts[:schema][:fields] })
        Google::Apis::BigqueryV2::JobConfigurationLoad.new(
          _opts
        )
      end

      def _query(opts)
        _opts = opts.dup
        Google::Apis::BigqueryV2::JobConfigurationQuery.new(
          _opts
        )
      end
    end
  end
end
