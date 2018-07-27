class Admin::WalletsController < ApplicationController

    before_action :authenticate_user!
    before_action :find_member, only: [:fund_page, 
                                       :update_wallet_detail, 
                                       :update_wallet_histories, 
                                       :paystack_wallet_fund, 
                                       :check_existing_balance,
                                       :pos_wallet_fund,
                                       :cash_wallet_fund]

    before_action :get_paystack_object, only: [:paystack_wallet_fund]


   def fund_page
    gon.amount, gon.email, gon.firstName = @member.subscription_plan.cost * 100, @member.email, @member.first_name
    gon.lastName, gon.displayValue = @member.last_name, @member.phone_number
    gon.publicKey = ENV["PAYSTACK_PUBLIC_KEY"]
    gon.member_id = @member.id
   end


   def paystack_wallet_fund
        paystack_verify = verify_paystack_payment
        if paystack_verify["status"] == true && paystack_verify["data"]["status"] == "success"
            amount = (paystack_verify["data"]["amount"] / 100 ).to_i
            existing_balance = check_existing_balance
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


   def pos_wallet_fund
      transaction_reference = wallet_member_params["pos_transactions_attributes"]["0"]["transaction_reference"]
      transaction_success_param = wallet_member_params["pos_transactions_attributes"]["0"]["transaction_success"]
      amount = wallet_member_params["pos_transactions_attributes"]["0"]["amount_received"].to_i
      transaction_success = true?(transaction_success_param)
      if !transaction_reference.nil? && transaction_success == true && amount.class == Integer
        existing_balance = check_existing_balance
        new_balance = existing_balance + amount
        fund_method = 1
        update_wallet_detail(amount, existing_balance, new_balance)
        update_wallet_histories(amount, existing_balance, new_balance, fund_method)
        create_pos_transaction(transaction_reference, transaction_success_param, amount)
        redirect_to member_profile_path(@member)
      else
        flash[:notice] = "Check to ensure the right values are provided!"
        redirect_to wallet_fund_page_path(@member)
      end  
   end

   def cash_wallet_fund
        amount = wallet_member_params["cash_transactions_attributes"]["0"]["amount_received"].to_i
        if amount.class == Integer
            existing_balance = check_existing_balance
            new_balance = existing_balance + amount
            fund_method = 2
            update_wallet_detail(amount, existing_balance, new_balance)
            update_wallet_histories(amount, existing_balance, new_balance, fund_method)
            create_cash_transaction(amount)
            redirect_to member_profile_path(@member)
        else
            flash[:notice] = "Check to ensure the right values are provided!"
            redirect_to wallet_fund_page_path(@member)
        end  
   end



    private
   
    def true?(obj)
        obj.to_s == "true"
    end
    
    def find_member
        @member = Member.find(params[:id].to_i) 
    end

    def check_existing_balance
        balance = @member.wallet_detail ? @member.wallet_detail.current_balance : 0
    end

    def create_cash_transaction(cash_received)
        cash_transaction = @member.cash_transactions.create(
                                        amount_received: cash_received,
                                        cash_received_by: current_user.fullname,
                                        service_paid_for: "Funded Wallet",
        )
        return cash_transaction
    end


    def update_wallet_detail(amount, existing_balance, new_balance)
        amount_last_used = @member.wallet_detail.amount_last_used ? @member.wallet_detail.amount_last_used : 0 
        total_funded = @member.wallet_detail.total_amount_funded ?  @member.wallet_detail.total_amount_funded : 0
        total_amount_used = @member.wallet_detail.total_amount_used ? @member.wallet_detail.total_amount_used : 0
        current_wallet_expiry_date = @member.wallet_detail.wallet_expiry_date ||= DateTime.now
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

    def create_pos_transaction(transaction_reference, transaction_success_param, amount)
        pos_transaction = @member.pos_transactions.create(
                                        amount_received: amount,
                                        transaction_success: transaction_success_param,
                                        transaction_reference: transaction_reference,
                                        processed_by: current_user.fullname )
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

    def wallet_member_params
        params.require(:member)
            .permit(
                    pos_transactions_attributes: [:transaction_success, :transaction_reference, :processed_by, :amount_received, :_destroy],
                    cash_transactions_attributes: [:amount_received, :cash_received_by, :service_paid_for, :_destroy]
            )
    end

end
