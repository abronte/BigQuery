module BigQuery
  class Client
    module Hashable

      def process_value(val, convert_key_proc)
        case val
        when Hash
          Hash[val.map {|k, v| [convert_key_proc.call(k), process_value(v, convert_key_proc)] }]
        when Array
          val.map{ |v| process_value(v, convert_key_proc) }
        else
          val
        end
      end
    end
  end
end
