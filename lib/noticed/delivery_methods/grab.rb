module Noticed
  module DeliveryMethods
    class Grab < DeliveryMethod
      required_options :url, :headers, :message

      def deliver
        post_request evaluate_option(:url), headers: evaluate_option(:headers), message: evaluate_option(:message)
      end
    end
  end
end
