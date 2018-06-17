class Admin::MembersController < Devise::RegistrationsController
    prepend_before_action :require_no_authentication, only: [:new, :create, :cancel]
    
    require 'securerandom'


    def index
    end

    def new 
      @subscription_plans = SubscriptionPlan.all  
      @payment_methods = PaymentMethod.all
      @fitness_goals = FitnessGoal.all
      build_resource
      yield resource if block_given?
      respond_with resource
    end


    def create
        new_params = new_member_params.clone
        new_params[:password] = SecureRandom.hex(7)
        new_params[:password_confirmation] = new_params[:password]
        build_resource(new_params)
        if resource.save
          session[:member_id] = resource.id
          flash[:notice] = "User created! Receive Payment & Complete the Registration Process"
          redirect_to admin_member_steps_path
        else
          clean_up_passwords resource
          respond_with resource
        end
    end

    private

    def new_member_params
        params.require(:member)
            .permit(:email,
                    :password,
                    :password_confirmation,
                    :first_name,
                    :last_name,
                    :subscription_plan_id,
                    :payment_method_id,
                    :fitness_goal_id,
                    pos_transactions_attributes: [:id, :transaction_success, :transaction_reference, :processed_by, :_destroy]
                    cash_transactions_attributes: [:id, :amount_received, :cash_received_by, :service_paid_for, :_destroy]
            )
    end
end
