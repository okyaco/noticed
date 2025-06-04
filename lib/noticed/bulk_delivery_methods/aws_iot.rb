require 'aws-sdk-iotdataplane'

module Noticed
  module BulkDeliveryMethods
    class AwsIot < BulkDeliveryMethod
      required_options :url, :credentials, :message

      def deliver
        endpoint = evaluate_option(:url)
        credentials = evaluate_option(:credentials)
        message  = evaluate_option(:message)

        client = Aws::IoTDataPlane::Client.new(
          endpoint: endpoint,
          region: credentials[:region],
          credentials: Aws::Credentials.new(credentials[:access_key_id], credentials[:secret_access_key])
        )

        client.publish(
          topic: message.fetch(:topic),
          payload: serialise_payload(message.fetch(:payload)),
          qos: message.fetch(:qos, 0),
          retain: message.fetch(:retain, false)
        )
      end

      private

      def serialise_payload(payload)
        payload.is_a?(String) ? payload : payload.to_json
      end
    end
  end
end
