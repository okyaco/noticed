require "test_helper"

class AwsIotBulkDeliveryMethodTest < ActiveSupport::TestCase
  setup do
    @delivery_method = Noticed::BulkDeliveryMethods::AwsIot.new
  end

  test "publishes to AWS IoT with correct options" do
    mock_client = Minitest::Mock.new
    mock_client.expect :publish, true do |**args|
      assert_equal "nimble/orders", args[:topic]
      assert_equal "{\"id\":123}", args[:payload]
      assert_equal 1, args[:qos]
      assert_equal true, args[:retain]
    end

    Aws::IoTDataPlane::Client.stub :new, mock_client do
      set_config(
        url: "https://test.iot.ap-southeast-2.amazonaws.com",
        credentials: {
          region: "ap-southeast-2",
          access_key_id: "FAKEKEY",
          secret_access_key: "FAKESECRET"
        },
        message: {
          topic: "nimble/orders",
          payload: { id: 123 },
          qos: 1,
          retain: true
        }
      )

      assert_nothing_raised do
        @delivery_method.deliver
      end
    end

    mock_client.verify
  end

  test "uses default qos 0 and retain false when not set" do
    mock_client = Minitest::Mock.new
    mock_client.expect :publish, true do |**args|
      assert_equal 0, args[:qos]
      assert_equal false, args[:retain]
    end

    Aws::IoTDataPlane::Client.stub :new, mock_client do
      set_config(
        url: "https://test.iot.ap-southeast-2.amazonaws.com",
        credentials: {
          region: "ap-southeast-2",
          access_key_id: "FAKEKEY",
          secret_access_key: "FAKESECRET"
        },
        message: {
          topic: "nimble/orders",
          payload: { id: 123 }
        }
      )

      assert_nothing_raised do
        @delivery_method.deliver
      end
    end

    mock_client.verify
  end

  test "does not double encode string payload" do
    mock_client = Minitest::Mock.new
    mock_client.expect :publish, true do |**args|
      assert_equal "raw string", args[:payload]
    end

    Aws::IoTDataPlane::Client.stub :new, mock_client do
      set_config(
        url: "https://test.iot.ap-southeast-2.amazonaws.com",
        credentials: {
          region: "ap-southeast-2",
          access_key_id: "FAKEKEY",
          secret_access_key: "FAKESECRET"
        },
        message: {
          topic: "nimble/orders",
          payload: "raw string"
        }
      )

      @delivery_method.deliver
    end

    mock_client.verify
  end

  private

  def set_config(config)
    @delivery_method.instance_variable_set :@config, ActiveSupport::HashWithIndifferentAccess.new(config)
  end
end
