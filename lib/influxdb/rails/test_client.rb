module InfluxDB
  module Rails
    class TestClient
      cattr_accessor :metrics do
        []
      end

      def write_point(name, options = {}, _time_precision = nil, _retention_policy = nil)
        metrics << options.merge(name: name)
      end
    end
  end
end
