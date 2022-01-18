require "spec_helper"

RSpec.describe InfluxDB::Rails::Metric do
  let(:config) { InfluxDB::Rails::Configuration.new }
  let(:timestamp) { Time.zone.now }
  let(:metric) do
    InfluxDB::Rails::Metric.new(configuration: config, timestamp: timestamp, values: { a: 1 })
  end
  let(:client) { instance_double("client", write_point: nil) }

  before do
    allow(metric).to receive(:client) { client }
  end

  describe "without retention_policy specified" do
    it "push the metrics correctly" do
      metric.write
      data = { values: { a: 1 }, timestamp: timestamp.utc.to_i }
      expect(client).to have_received(:write_point)
        .with(config.measurement_name, a_hash_including(data))
    end
  end

  describe "with retention_policy specified" do
    before { config.client.retention_policy = "fancy_policy" }

    it "push the metrics correctly" do
      metric.write
      data = { values: { a: 1 }, timestamp: timestamp.utc.to_i }
      expect(client).to have_received(:write_point)
        .with(config.measurement_name, a_hash_including(data), nil, "fancy_policy")
    end
  end
end
