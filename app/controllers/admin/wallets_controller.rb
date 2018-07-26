class Admin::WalletsController < ApplicationController

    before_action :authenticate_user!
    before_action :find_member, only: [:fund_page]

   def fund_page
    gon.amount, gon.email, gon.firstName = @member.subscription_plan.cost * 100, @member.email, @member.first_name
    gon.lastName, gon.displayValue = @member.last_name, @member.phone_number
    gon.publicKey = ENV["PAYSTACK_PUBLIC_KEY"]
    gon.member_id = @member.id
    # session[:member_id] = @member.id
   end


   def paystack_fund
    binding.pry
   end



    private
   
    def find_member
        @member = Member.find(params[:id]) 
    end


end
