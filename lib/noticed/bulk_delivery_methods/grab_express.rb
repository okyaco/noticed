# frozen_string_literal: true

module Noticed
  module BulkDeliveryMethods
    class GrabExpress < BulkDeliveryMethod
      required_options :url, :headers, :before_deliver
      attr_accessor :response, :before_deliver

      before_deliver :before_deliver

      after_deliver do
        # Call the lambda explicitly as evaluate_option prematurely calls the lambda before the response is ready
        @after_deliver.call(@response) if @after_deliver.present?
      end

      def deliver
        @before_deliver = evaluate_option(:before_deliver)
        @after_deliver = evaluate_option(:after_deliver)

        # Grab uses POST HTTP method to create deliveries, and DELETE HTTP method to cancel the deliveries
        method = evaluate_option(:method) || 'POST'
        method = method.to_s.upcase

        @response = case method
                    when 'DELETE'
                      delete_request evaluate_option(:url), headers: evaluate_option(:headers)
                    when 'POST'
                      post_request evaluate_option(:url), headers: evaluate_option(:headers),
                                                          json: evaluate_option(:json)
                    end
      end
    end
  end
end
