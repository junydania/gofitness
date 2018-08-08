class ProcessWebhookJob < ApplicationJob
  queue_as :process_web_hook

  require 'membership'
  include Membership

  def perform(options)

  end

end
