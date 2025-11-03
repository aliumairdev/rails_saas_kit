module Pay
  class Webhook
    # Handle subscription created event
    def self.handle_subscription_created(event)
      subscription = event.data.object

      # Find the customer and update their subscription status
      customer = Pay::Customer.find_by(processor: "stripe", processor_id: subscription.customer)
      return unless customer

      Rails.logger.info "Subscription created for customer #{customer.owner_id}: #{subscription.id}"
    end

    # Handle subscription updated event
    def self.handle_subscription_updated(event)
      subscription = event.data.object

      customer = Pay::Customer.find_by(processor: "stripe", processor_id: subscription.customer)
      return unless customer

      # Update subscription in our database
      pay_subscription = customer.owner.payment_processor.subscriptions.find_by(
        processor_id: subscription.id
      )

      if pay_subscription
        pay_subscription.sync!(subscription)
        Rails.logger.info "Subscription updated for customer #{customer.owner_id}: #{subscription.id}"
      end
    end

    # Handle subscription canceled event
    def self.handle_subscription_canceled(event)
      subscription = event.data.object

      customer = Pay::Customer.find_by(processor: "stripe", processor_id: subscription.customer)
      return unless customer

      Rails.logger.info "Subscription canceled for customer #{customer.owner_id}: #{subscription.id}"

      # Optionally send notification email
      # SubscriptionMailer.subscription_canceled(customer.owner).deliver_later
    end

    # Handle payment failed event
    def self.handle_payment_failed(event)
      invoice = event.data.object

      customer = Pay::Customer.find_by(processor: "stripe", processor_id: invoice.customer)
      return unless customer

      Rails.logger.error "Payment failed for customer #{customer.owner_id}: #{invoice.id}"

      # Send notification email
      # SubscriptionMailer.payment_failed(customer.owner, invoice).deliver_later
    end

    # Handle trial will end event
    def self.handle_trial_will_end(event)
      subscription = event.data.object

      customer = Pay::Customer.find_by(processor: "stripe", processor_id: subscription.customer)
      return unless customer

      Rails.logger.info "Trial ending soon for customer #{customer.owner_id}: #{subscription.id}"

      # Send notification email
      # SubscriptionMailer.trial_ending(customer.owner, subscription).deliver_later
    end
  end
end
