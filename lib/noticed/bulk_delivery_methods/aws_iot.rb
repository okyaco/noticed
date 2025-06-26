require 'aws-sdk-iotdataplane'

module Noticed
  module BulkDeliveryMethods
    class AwsIot < BulkDeliveryMethod
      required_options :url, :region, :access_key_id, :secret_access_key, :topic, :payload, :qos, :retain

      def deliver
        url = evaluate_option(:url)
        region = evaluate_option(:region)
        access_key_id = evaluate_option(:access_key_id)
        secret_access_key = evaluate_option(:secret_access_key)
        topic = evaluate_option(:topic)
        payload = evaluate_option(:payload)
        qos = evaluate_option(:qos)
        retain = evaluate_option(:retain)

        client = Aws::IoTDataPlane::Client.new(
          endpoint: url,
          region: region,
          credentials: Aws::Credentials.new(access_key_id, secret_access_key)
        )

        client.publish(
          topic: topic,
          payload: payload,
          qos: qos,
          retain: retain
        )
      end
    end
  end
end
