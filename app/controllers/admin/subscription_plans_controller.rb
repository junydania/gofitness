class Admin::SubscriptionPlansController < ApplicationController

    load_and_authorize_resource param_method: :plan_param
    
    skip_authorize_resource :only => :check_recurring


    helper ApplicationHelper

    before_action :authenticate_user!
    before_action   :find_plan, only: [:edit, :update, :show, :update_plan_record]
    
    def index
        @subscription_plans = SubscriptionPlan.all
    end

    def new
        @subscription_plan = SubscriptionPlan.new
        @feature = Feature.new
    end

    def show
        @subscription_plan = SubscriptionPlan.find(params[:id])
    end

    def create
        if plan_param[:recurring] == "true"
            result = create_paystack_plan(plan_param)
            if result["status"] == true
                paystack_plan_code = result["data"]["plan_code"]
                @subscription_plan = SubscriptionPlan.create(plan_param)
                @subscription_plan.update_attribute(:paystack_plan_code, paystack_plan_code)
                    flash[:notice] = "New Plan Successfully Created in System & Paystack"
                    redirect_to new_admin_subscription_plan_path
            else 
                flash[:error] = "Check to ensure the form is properly filled"
                redirect_to new_admin_subscription_plan_path
            end
        else
            @subscription_plan = SubscriptionPlan.new(plan_param)
            if @subscription_plan.save
                flash[:notice] = "New Plan Successfully Created in the System"
                redirect_to new_admin_subscription_plan_path
            else
                flash[:error] = "Error creating new record! Check to ensure all fields are filled"
                redirect_to new_admin_subscription_plan_path
            end
        end
    end

    def edit
        render
    end


    def update
        if @plan.paystack_plan_code.nil?
            if @plan.update(plan_param) 
                redirect_to admin_subscription_plan_path(@plan) 
            else
                flash[:error] = "#{@plan.errors.full_messages.first}"
                redirect_to edit_admin_subscription_plan_path
            end         
        else
            plan_id = @plan.paystack_plan_code
            paystackObj = instantiate_paystack
            plan_present = fetch_paystack_plan(plan_id, paystackObj)
            update_paystack_plan = plan_present["status"] == true ? update_paystack(plan_id, paystackObj) : failed_plan_fetch
            update_paystack_plan["status"] == true ? update_plan_record : failed_paystack_update
        end
    end

    def check_recurring
        selected_plan = params[:plan]
        sub_plan = SubscriptionPlan.find(selected_plan)
        if sub_plan.recurring == false
            render status: 200, json: {
                message: "non-recurring"
            }
        else
            render status: 200, json: {
                message: "recurring"
            }
        end
    end

    private

    def instantiate_paystack
        paystackObj = Paystack.new
        return paystackObj
    end  

    def fetch_paystack_plan(plan_id, paystackObj)        
        plans = PaystackPlans.new(paystackObj)
        result = plans.get(plan_id)
    end

    def update_paystack(plan_id, paystackObj)
        amount = plan_param[:cost].to_i * 100
        duration = plan_param[:duration].to_s
        plan_name = plan_param[:plan_name]
        plans = PaystackPlans.new(paystackObj)
        result = plans.update(
                plan_id,
                :name => plan_name,
                :amount => amount,
			    :interval => duration,
			)
    end

    def update_plan_record
        if @plan.update(plan_param)
            flash[:notice] = "Plan Updated"
            redirect_to admin_subscription_plan_path(@plan)
        else
            flash[:notice] = "#{@plan.errors.full_messages.first}"
            redirect_to edit_admin_subscription_plan_path
        end
    end
    
    def failed_plan_fetch
        flash[:notice] = "Couldn't retrieve plan from Paystack"
        redirect_to edit_admin_subscription_plan_path
    end

    def failed_paystack_update
        flash[:notice] = "Plan was not succesfully updated on Paystack"
        redirect_to edit_admin_subscription_plan_path
    end

    def create_paystack_plan(plan_param)
        paystackObj = instantiate_paystack
        plans = PaystackPlans.new(paystackObj)
        data = {
                :name => plan_param[:plan_name],
                :description =>  plan_param[:description],
                :amount => plan_param[:cost].to_i * 100,
                :interval => plan_param[:duration],
                :currency => "NGN"
        }
        result = plans.create(data)
        return result
    end

    def find_plan
        @plan = SubscriptionPlan.find(params[:id])
    end

    
    def plan_param
        params.require(:subscription_plan) 
            .permit(:plan_name,
                    :cost,
                    :description,
                    :duration,
                    :group_plan,
                    :recurring,
                    :no_of_group_members,
                    :paystack_plan_code,
                    :organization_package,
                    :allowed_visitation_count,
                    feature_ids: [] )
    end


end
