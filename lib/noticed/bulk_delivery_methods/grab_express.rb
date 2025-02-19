module Noticed
  module BulkDeliveryMethods
    class GrabExpress < BulkDeliveryMethod
      required_options :url, :headers, :json, :after_deliver
      attr_accessor :request_body, :response, :after_deliver

      after_deliver :after_deliver

      def deliver
        @request_body = evaluate_option(:json)
        @after_deliver = evaluate_option(:after_deliver)

        @response = post_request evaluate_option(:url), headers: evaluate_option(:headers), json: @request_body
      end
    end
  end
end
