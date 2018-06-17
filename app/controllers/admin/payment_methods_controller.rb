class Admin::PaymentMethodsController < ApplicationController

    before_action :find_payment_method, only: [:show, :edit, :update, :destroy] 
    before_action :authenticate_user!

    def index
        @payment_methods = PaymentMethod.all
        @payment = PaymentMethod.new
    end

    def create
        @new_payment = PaymentMethod.new(payment_param)
        if @new_payment.save
            flash[:notice] = "New Payment Successfully Created"
            redirect_to admin_payment_methods_path
        else
            redirect_to admin_payment_methods_path
        end
    end

    def edit
      respond_to do |format|
        format.js
      end
    end


    def update
        respond_to do |format|
            if @payment_method.update_attributes(payment_param)
                format.js { render action: 'index', status: :updated }
            else
                format.json { render json: @payment_method.errors, status: :unprocessable_entity }
            end
        end        
    end

    def destroy
        @payment_method.destroy
        redirect_to admin_fitness_goals_path
    end
    

    private

    def payment_param
        params.require(:payment_method) 
            .permit(:payment_system, :discount)
    end

    def find_payment_method
        @payment_method = PaymentMethod.find(params[:id])
    end


end
