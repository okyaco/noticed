module Noticed
  module BulkDeliveryMethods
    class Grab < BulkDeliveryMethod
      required_options :url, :headers, :json

      def deliver
        post_request evaluate_option(:url), headers: evaluate_option(:headers), json: evaluate_option(:json)
      end
    end
  end
end
