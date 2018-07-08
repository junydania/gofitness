class Admin::MembersController < Devise::RegistrationsController
    
    prepend_before_action :require_no_authentication, only: [:new, :create, :cancel]
    before_action :authenticate_user!
    before_action :find_member, only: [:renew_membership, :paystack_renewal, :cash_renewal, :pos_renewal ]

    require 'securerandom'


    def index
      @members = Member.all
    end

    def new
      @subscription_plans = SubscriptionPlan.all  
      @payment_methods = PaymentMethod.all
      @fitness_goals = FitnessGoal.all
      build_resource
      yield resource if block_given?
      respond_with resource
    end

    def edit
      @subscription_plans = SubscriptionPlan.all  
      @payment_methods = PaymentMethod.all
      @fitness_goals = FitnessGoal.all
      render :edit
    end

    def show
      @member = Member.find(params[:id])
    end


    def create
        new_params = new_member_params.clone
        new_params[:password] = SecureRandom.hex(7)
        new_params[:password_confirmation] = new_params[:password]
        ## Implement feature to mail login address and password to new member
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

    def renew_membership
      gon.amount, gon.email, gon.firstName = @member.subscription_plan.cost * 100, @member.email, @member.first_name
      gon.lastName, gon.displayValue = @member.last_name, @member.phone_number
      gon.publicKey = ENV["PAYSTACK_PUBLIC_KEY"]
    end

    def cash_renewal
    end

    def pos_renewal
    end

    def paystack_renewal
      if  check_paystack_subscription == true
        
      else
      end

      


    end


  #   subscription_id = "123456778"
	# subscriptions = PaystackSubscriptions.new(paystackObj)
	# result = subscriptions.get(subscription_id)
  # subscription =  result['data']
  
 
    private

    def find_member
      @member = Member.find(session[:member_id]) 
    end

    def check_paystack_subscription
      paystack_subscription_code = @member.paystack_subscription_code
      subscription = PaystackSubscriptions.new(paystackObj)
      result = subscriptions.get(paystack_subscription_code)
      subscription =  result['status']
    end

    def enable_paystack_subscription
      
    end

    def new_member_params
        params.require(:member)
            .permit(:email,
                    :password,
                    :password_confirmation,
                    :first_name,
                    :last_name,
                    :image,
                    :subscription_plan_id,
                    :payment_method_id,
                    :fitness_goal_id,
                    pos_transaction_attributes: [:id, :transaction_success, :transaction_reference, :processed_by, :_destroy],
                    cash_transaction_attributes: [:id, :amount_received, :cash_received_by, :service_paid_for, :_destroy]
            )
    end


end
