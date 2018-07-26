class Admin::WalletsController < ApplicationController

    before_action :authenticate_user!
    before_action :find_member, only: [:fund_page, :update_wallet_detail, :update_wallet_histories]
    before_action :get_paystack_object, only: [:paystack_wallet_fund]


   def fund_page
    gon.amount, gon.email, gon.firstName = @member.subscription_plan.cost * 100, @member.email, @member.first_name
    gon.lastName, gon.displayValue = @member.last_name, @member.phone_number
    gon.publicKey = ENV["PAYSTACK_PUBLIC_KEY"]
    gon.member_id = @member.id
   end


   def paystack_wallet_fund
        member = Member.find(params[:id].to_i)
        paystack_verify = verify_paystack_payment
        if paystack_verify["status"] == true && paystack_verify["data"]["status"] == "success"
            amount = paystack_verify["data"]["amount"]
            existing_balance = member.wallet_detail ? member.wallet_detail.current_balance : 0
            new_balance = existing_balance + amount
            fund_method = 0
            update_wallet_detail(amount, existing_balance, new_balance)
            update_wallet_histories(amount, existing_balance, new_balance, fund_method)
            render status: 200, json: {
                message: "success"
            }
        else
            render status: 200, json: {
                message: "failed"
            }
        end
   end


    private
   
    def find_member
        @member = Member.find(params[:id]) 
    end


    def update_wallet_detail(amount, existing_balance, new_balance)
        amount_last_used = @member.wallet_detail.amount_last_used ? @member.wallet_detail.amount_last_used : 0 
        total_funded = @member.wallet_detail.total_amount_funded ?  @member.wallet_detail.total_amount_funded : 0
        total_amount_used = @member.wallet_detail.total_amount_used ? @member.wallet_detail.total_amount_used : 0
        current_wallet_expiry_date = @member.wallet_expiry_date ||= DateTime.now
        new_wallet_expiry_date = current_wallet_expiry_date + 180
        @member.wallet_detail.update(
            current_balance: new_balance,
            total_amount_funded: total_funded + amount,
            amount_last_funded: amount, 
            total_amount_used: total_amount_used,
            amount_last_used: amount_last_used,
            wallet_expiry_date: new_wallet_expiry_date,
            wallet_status: 0,
            date_last_funded: DateTime.now
        )
    end


    def update_wallet_histories(amount, existing_balance, new_balance, fund_method)
        @member.wallet_histories.create(
             amount_paid_in: amount,
             wallet_previous_balance: existing_balance,
             amount_used: 0,
             processed_by: current_user.fullname,
             wallet_new_balance: new_balance,
             amount_last_used: 0,
             wallet_fund_method: fund_method )
    end


    def verify_paystack_payment
        reference = params[:reference_code].to_s
        transactions = PaystackTransactions.new(@paystackObj)
        result = transactions.verify(reference)
        return result
    end


    def get_paystack_object
        @paystackObj = Paystack.new
    end

end

