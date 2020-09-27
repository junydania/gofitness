class PauseAllMembersJob < ApplicationJob
    queue_as :pause_all_members

    require 'membership'

    include Membership

    def perform(options)
      if options['event'] == 'charge.success'
        Membership::SubscriptionActivity.new(options).call
        Accounting::Entry.new(options).card_entry
      end
    end
  end