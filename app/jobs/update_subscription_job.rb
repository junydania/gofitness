class UpdateSubscriptionJob < ApplicationJob
  queue_as :default

  # rescue_from(ActiveRecord::RecordNotFound) do |exception|
  #   # Do something with the exception
  # end
  
  def perform 
    Member.joins(:account_detail).where(account_details: {member_status: 0}).find_each do |member|
      if DateTime.now > member.account_detail.expiry_date.to_datetime 
        member.account_detail.member_status = 1
        member.save
      end
    end
  end
end

