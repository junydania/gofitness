module Membership

    class SubscriptionActivity

        def initialize(options)
            @member = Member.find(options['member_id'])
            @subscribe_date = options['data']['period_start'].to_datetime
            @expiry_date = options['data']['period_end'].to_datetime
            @amount = options['data']['amount'].to_i
            @paid_date = options['data']['paid_at'].to_datetime
            @auth_code = options['data']['authorization']['authorization_code']
            @subscription_code = options['data']['subscription']['subscription_code']
            @transaction_reference = options['data']['transaction']['reference']
            @subscription_status = 0
        end

        def call
            amount = @amount
            update_account_detail(amount)
            create_loyalty_history(amount)
            create_subscription_history
            create_general_transaction(amount)
            update_member_paystack_auths
        end


        def update_member_paystack_auths
            @member.paystack_subscription_code = @subscription_code
            @member.paystack_auth_code = @auth_code
            @member.save
        end
        

        def update_account_detail(amount)
            loyalty_balance = loyalty_new_balance(amount)
            gym_plan = retrieve_gym_plan
            account_update = @member.build_account_detail(
                                        subscribe_date: @subscribe_date,
                                        expiry_date: @expiry_date,
                                        member_status: 0,
                                        amount: @amount,
                                        loyalty_points_balance: loyalty_balance,
                                        loyalty_points_used: 0,
                                        gym_plan: gym_plan,
                                        recurring_billing: true,
                                        gym_attendance_status: 1 )
        end
    
        
       def loyalty_new_balance(amount)
         loyalty_earned = get_loyalty_points(amount)
         current_loyalty_balance = loyalty_current_balance
         new_loyalty_balance = loyalty_earned + current_loyalty_balance
         return new_loyalty_balance
       end
       
    
       def create_loyalty_history(amount)
            points = get_loyalty_points(amount)
            new_loyalty_balance = loyalty_new_balance(amount) 
            loyalty_history = @member.loyalty_histories.create(
                points_earned: points,
                points_redeemed: 0,
                loyalty_transaction_type: 0,
                loyalty_balance: new_loyalty_balance,
             )
        end

    
        def get_loyalty_points(amount)
            point = Loyalty.find_by(loyalty_type: 1).loyalty_points_percentage ||= 10
            point = ((point.to_f * 0.01) * amount).to_i
        end
    
        def loyalty_current_balance
            @member.account_detail.loyalty_points_balance
        end
            
        def retrieve_payment_method
            @member.payment_method.payment_system
        end
        
        def create_subscription_history
            subscription_history = @member.subscription_histories.create(
                subscribe_date: @subscribe_date,
                expiry_date: @expiry_date,
                subscription_type: 1,
                subscription_plan: retrieve_gym_plan,
                amount: @amount,
                payment_method: retrieve_payment_method,
                member_status: 0,
                subscription_status: @subscription_status,
            )
        end
    
    
        def retrieve_amount
            amount = @member.subscription_plan.cost
        end
    
    
        def retrieve_gym_plan
            plan = @member.subscription_plan.plan_name
            return plan
        end
    
    
        def set_subscribe_date
            date = DateTime.now.strftime('%d-%m-%Y %H:%M:%S')
        end
    
        def set_expiry_date(subscribe_date)
            expiry_date = DateTime.new
            if @member.subscription_plan.duration == "daily"
                expiry_date =  (DateTime.parse(subscribe_date) + 1).strftime('%d-%m-%Y %H:%M:%S')
            elsif @member.subscription_plan.duration == "weekly"
                expiry_date =  (DateTime.parse(subscribe_date) + 7).strftime('%d-%m-%Y %H:%M:%S')
            elsif @member.subscription_plan.duration == "monthly"
                expiry_date =  (DateTime.parse(subscribe_date) + 30).strftime('%d-%m-%Y %H:%M:%S')
            elsif @member.subscription_plan.duration == "quarterly"
                expiry_date =  (DateTime.parse(subscribe_date) + 90).strftime('%d-%m-%Y %H:%M:%S')
            elsif @member.subscription_plan.duration == "annually"
                expiry_date = (DateTime.parse(subscribe_date).next_year).strftime('%d-%m-%Y %H:%M:%S')
            end
            expiry_date
        end
    

        def get_subscription_plan_code
            @member.subscription_plan.paystack_plan_code
        end

        
        def create_general_transaction(amount)
            GeneralTransaction.create(
                member_fullname: @member.fullname,
                transaction_type: 0,
                subscribe_date: @subscribe_date,
                expiry_date: @expiry_date,
                staff_responsible: "Administrator",
                payment_method: retrieve_payment_method,
                loyalty_earned: get_loyalty_points(amount),
                loyalty_redeemed: 0,
                membership_plan: retrieve_gym_plan,
                membership_status: 0,
                customer_code: @member.customer_code,
                member_email: @member.email,
                loyalty_type: 1,
                amount: @amount )
        end 
    end
end
