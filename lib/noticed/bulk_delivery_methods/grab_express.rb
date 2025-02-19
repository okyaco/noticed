module Noticed
  module BulkDeliveryMethods
    class GrabExpress < BulkDeliveryMethod
      required_options :url, :headers, :json, :before_deliver, :after_deliver
      attr_accessor :response, :before_deliver, :after_deliver

      before_deliver :before_deliver

      after_deliver do
        # Call the lambda explicitly as evaluate_option prematurely calls the lambda before the response is ready
        @after_deliver.call(@response)
      end

      def deliver
        @before_deliver = evaluate_option(:before_deliver)
        @after_deliver = evaluate_option(:after_deliver)

        @response = post_request evaluate_option(:url), headers: evaluate_option(:headers), json: evaluate_option(:json)
      end
    end
  end
end
