require 'json'
require 'google/apis/bigquery_v2'
require 'google/api_client/auth/key_utils'
require 'big_query/version'
require 'big_query/errors'
require 'big_query/client'

module BigQuery
  include BigQuery::Errors
end


class String

  def underscore
    self.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end

  def camel_case_lower
    self.split('_').inject([]){ |buffer,e| buffer.push(buffer.empty? ? e : e.capitalize) }.join
  end
end

class Hash

  def deep_symbolize_keys
    symbolized_hash = {}
    self.each do |k, v|
      symbolized_hash[k.to_s.underscore.to_sym] = (v.is_a?(Hash) ? v.deep_symbolize_keys : v)
    end
    symbolized_hash
  end

  def deep_stringify_keys
    stringify_hash = {}
    self.each do |k, v|
      stringify_hash[k.to_s.camel_case_lower] = (v.is_a?(Hash) ? v.deep_stringify_keys : v)
    end
    stringify_hash
  end
end
