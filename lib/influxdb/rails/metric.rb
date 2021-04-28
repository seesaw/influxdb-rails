require "influxdb/rails/values"
require "influxdb/rails/tags"

module InfluxDB
  module Rails
    class Metric
      def initialize(configuration:, timestamp:, tags: {}, values: {})
        @configuration = configuration
        @timestamp = timestamp
        @tags = tags
        @values = values
      end

      def write
        client.write_point(
          configuration.measurement_name,
          options,
          configuration.client.time_precision,
          configuration.client.retention_policy
        )
      end

      private

      attr_reader :configuration, :tags, :values, :timestamp

      def options
        {
          values:    Values.new(values: values).to_h,
          tags:      Tags.new(tags: tags, config: configuration).to_h,
          timestamp: timestamp.utc.to_i,
        }
      end

      def client
        InfluxDB::Rails.client
      end
    end
  end
end
