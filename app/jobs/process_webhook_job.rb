class ProcessWebhookJob < ApplicationJob
  queue_as :process_web_hook

  require 'membership'
  require 'accounting'

  include Membership
  include Accounting
  
  def perform(options)
    if options['event'] == 'charge.success'
      Membership::SubscriptionActivity.new(options).call
      Accounting::Entry.new(options).card_entry
    end
  end
end