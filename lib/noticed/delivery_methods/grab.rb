module Noticed
  module DeliveryMethods
    class Grab < DeliveryMethod
      required_options :url, :headers, :message

      def deliver
        url = evaluate_option(:url)
        message = evaluate_option(:message)

        json = {
          value: message[:value]
        }

        post_request evaluate_option(:url), headers: evaluate_option(:headers), json: json
      end
    end
  end
end
