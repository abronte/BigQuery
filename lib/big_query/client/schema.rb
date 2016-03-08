module BigQuery
  class Client
    module Schema

      def normalize_schema(schema)
        schema.map do |s|
          if s.respond_to?(:[])
            f = {
              name: (s[:name] || s["name"]),
              type: (s[:type] || s["type"])
            }
            f[:mode] = (s[:mode] || s["mode"]) if (s[:mode] || s["mode"])
            if (sub_fields = (s[:fields] || s["fields"]))
              f[:fields] = normalize_schema(sub_fields)
            end
          else
            f = {
              name: s.name,
              type: s.type
            }
            f[:mode] = f.mode if f.mode
            if (sub_fields = f.fields)
              f[:fields] = normalize_schema(sub_fields)
            end
          end
          f
        end
      end
    end
  end
end
