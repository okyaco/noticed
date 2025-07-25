require "googleauth"

module Noticed
  module DeliveryMethods
    class Fcm < DeliveryMethod
      required_option :credentials, :device_tokens, :json

      def deliver
        evaluate_option(:device_tokens).each do |device_token|
          send_notification device_token
        end
      end

      def send_notification(device_token)
        # We need to add `Content-Type: application/json` because without it, the payload gets double-encoded as a string (with extra \ escapes), causing FCM to reject it with Invalid JSON payload errors.
        # Root cause: The [original gem](https://github.com/excid3/noticed/blob/d63ddeef0e6561e1c2eb39581f384cea321db415/lib/noticed/api_client.rb#L20) still has "Content-Type", while in our [forked gem](https://github.com/okyaco/noticed/blob/0b12663ab73454461affcff993c43b58c905df55/lib/noticed/api_client.rb#L20C6-L20C111) we commented it out.
        post_request("https://fcm.googleapis.com/v1/projects/#{credentials[:project_id]}/messages:send",
          headers: {authorization: "Bearer #{access_token}", "Content-Type": "application/json"},
          json: format_notification(device_token))
      rescue Noticed::ResponseUnsuccessful => exception
        if exception.response.code == "404" && config[:invalid_token]
          notification.instance_exec(device_token, &config[:invalid_token])
        else
          raise
        end
      end

      def format_notification(device_token)
        method = config[:json]
        if method.is_a?(Symbol) && event.respond_to?(method, true)
          event.send(method, device_token)
        else
          notification.instance_exec(device_token, &method)
        end
      end

      def credentials
        @credentials ||= begin
          value = evaluate_option(:credentials)
          case value
          when Hash
            value
          when Pathname
            load_json(value)
          when String
            load_json(Rails.root.join(value))
          else
            raise ArgumentError, "FCM credentials must be a Hash, String, Pathname, or Symbol"
          end
        end
      end

      def load_json(path)
        JSON.parse(File.read(path), symbolize_names: true)
      end

      def access_token
        @authorizer ||= (evaluate_option(:authorizer) || Google::Auth::ServiceAccountCredentials).make_creds(
          json_key_io: StringIO.new(credentials.to_json),
          scope: "https://www.googleapis.com/auth/firebase.messaging"
        )
        @authorizer.fetch_access_token!["access_token"]
      end
    end
  end
end
