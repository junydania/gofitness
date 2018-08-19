class ValidateWalletExpiryJob < ApplicationJob
  queue_as :validate_wallet

  # rescue_from(ActiveRecord::RecordNotFound) do |exception|
  #   # Do something with the exception
  # end
  
  def perform 
    Member.joins(:wallet_detail).where(wallet_details: {wallet_status: 0}).find_each do |member|
      wallet_expiry_date = member.wallet_detail.wallet_expiry_date.to_datetime
      if member.wallet_detail.current_balance > 0 && DateTime.now > wallet_expiry_date
        previous_balance = member.wallet_detail.current_balance
        member.wallet_detail.update(
          current_balance: 0,
          wallet_status: 1
        )
        member.wallet_histories.create(
          amount_paid_in: 0,
          wallet_previous_balance: previous_balance,
          amount_used: 0,
          processed_by: "Administrator",
          wallet_new_balance: 0,
        )
      end
    end
  end
end