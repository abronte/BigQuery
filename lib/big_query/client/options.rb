module BigQuery
  class Client
    module Options

      def deep_symbolize_keys(opts)
        convert_key_proc = Proc.new { |k| underscore(k.to_s).to_sym }
        Hash[opts.map { |k, v| [convert_key_proc.call(k), process_value(v, convert_key_proc)] }]
      end

      def underscore(str)
        str.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
      end
    end
  end
end
