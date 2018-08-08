class ProcessWebhookJob < ApplicationJob
  queue_as :default

  require 'membership'

  include Membership
  
  def perform(options)
    Membership::SubscriptionActivity.new(options).call
  end

end
