class Admin::ChargesController < ApplicationController

    before_action :set_member, only: [:show, :edit, :update, :destory]


    def index 
    end


    def show
    end


    private

    def set_charge
    end

    def charge_params
        params.require(:charge) 
        .permit(:service_plan, :amount, :payment_method, :duration)
    end
end

