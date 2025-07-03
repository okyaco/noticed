require "test_helper"

class AwsIotBulkDeliveryMethodTest < ActiveSupport::TestCase
  setup do
    @delivery_method = Noticed::BulkDeliveryMethods::AwsIot.new
  end

  test "publishes MQTT message to AWS IoT" do
    mock_client = Minitest::Mock.new
    mock_client.expect :publish, true do |**args|
      assert_equal "nimble/orders", args[:topic]
      assert_equal "{\"id\":123}", args[:payload]
      assert_equal 1, args[:qos]
      assert_equal true, args[:retain]
    end

    set_config(
      url: "https://test.iot.ap-southeast-2.amazonaws.com",
      region: "ap-southeast-2",
      access_key_id: "FAKEKEY",
      secret_access_key: "FAKESECRET",
      topic: "nimble/orders",
      payload: { id: 123 }.to_json,
      qos: 1,
      retain: true
    )

    Aws::IoTDataPlane::Client.stub :new, mock_client do
      assert_nothing_raised do
        @delivery_method.deliver
      end
    end

    mock_client.verify
  end

  private

  def set_config(config)
    @delivery_method.instance_variable_set :@config, ActiveSupport::HashWithIndifferentAccess.new(config)
  end
end
