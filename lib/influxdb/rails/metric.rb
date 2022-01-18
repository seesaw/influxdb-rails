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
        client.write_point(*write_point_arguments)
      end

      private

      attr_reader :configuration, :tags, :values, :timestamp

      def write_point_arguments
        arguments = [configuration.measurement_name, options]

        if configuration.client.retention_policy.present?
          arguments.push(nil, configuration.client.retention_policy)
        end

        arguments
      end

      def options
        {
          values:    Values.new(values: values).to_h,
          tags:      Tags.new(tags: tags, config: configuration).to_h,
          timestamp: timestamp_with_precision,
        }
      end

      def timestamp_with_precision
        InfluxDB.convert_timestamp(timestamp.utc, configuration.client.time_precision)
      end

      def client
        InfluxDB::Rails.client
      end
    end
  end
end
