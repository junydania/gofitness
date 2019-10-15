module Membership

    class SubscriptionActivity

        def initialize(options)
            @member = Member.find(options['member_id'])
            @paid_date = options['data']['paid_at']
            @subscribe_date = @paid_date
            @charge_plan = retrieve_gym_plan
            @channel = options['data']['authorization']['channel']
            @amount = options['data']['amount'].to_i / 100
            @auth_code = options['data']['authorization']['authorization_code']
            @transaction_reference = options['data']['reference']
            @subscription_status = 0
            @expiry_date = set_expiry_date
        end

        def call
            update_account_detail
            create_loyalty_history
            create_subscription_history
            create_charge
            create_general_transaction
            update_member_paystack_auths
            process_charge_success
        end


        def process_charge_success
            @member.paystack_charges.create(
                paid_at: @paid_date,
                plan: @charge_plan,
                amount: @amount,
                channel: @channel,
            )
        end

        def create_charge
            fund_method = retrieve_payment_method
            duration = @member.subscription_plan.duration
            charge = @member.charges.new(service_plan: "Membership Renewal",
                                        amount: @amount,
                                        payment_method: fund_method,
                                        duration: duration,
                                        gofit_transaction_id: SecureRandom.hex(4) )
            if charge.save
                MemberMailer.renewal(@member).deliver_later
            end
        end

        def update_member_paystack_auths
            @member.paystack_auth_code = @auth_code
            @member.save
        end
        

        def update_account_detail
            loyalty_balance = loyalty_new_balance
            gym_plan = retrieve_gym_plan
            account_update = @member.account_detail.update!(
                                        subscribe_date: @subscribe_date,
                                        expiry_date: @expiry_date,
                                        member_status: 0,
                                        amount: @amount,
                                        loyalty_points_balance: loyalty_balance,
                                        gym_plan: gym_plan,
                                        recurring_billing: true )
        end
    
        
       def loyalty_new_balance
         loyalty_earned = get_loyalty_points
         current_loyalty_balance = loyalty_current_balance
         new_loyalty_balance = loyalty_earned + current_loyalty_balance
         return new_loyalty_balance
       end
       
    
       def create_loyalty_history
            points = get_loyalty_points
            new_loyalty_balance = loyalty_new_balance
            loyalty_history = @member.loyalty_histories.create(
                points_earned: points,
                points_redeemed: 0,
                loyalty_transaction_type: 0,
                loyalty_balance: new_loyalty_balance,
             )
        end

    
        def get_loyalty_points
            point = Loyalty.find_by(loyalty_type: 1).loyalty_points_percentage ||= 10
            point = ((point.to_f * 0.01) * @amount).to_i
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
            @member.subscription_plan.plan_name
        end

        
        def set_subscribe_date
            date = DateTime.now.strftime('%d-%m-%Y %H:%M:%S')
        end
    

        def set_expiry_date
            plan_duration = @member.subscription_plan.duration
            if plan_duration == "daily"
                expiry_date =  (DateTime.parse(@subscribe_date) + 1).strftime('%d-%m-%Y %H:%M:%S')
            elsif plan_duration == "weekly"
                expiry_date =  (DateTime.parse(@subscribe_date) + 7).strftime('%d-%m-%Y %H:%M:%S')
            elsif plan_duration == "monthly"
                expiry_date =  (DateTime.parse(@subscribe_date) + 30).strftime('%d-%m-%Y %H:%M:%S')
            elsif plan_duration == "quarterly"
                expiry_date =  (DateTime.parse(@subscribe_date) + 90).strftime('%d-%m-%Y %H:%M:%S')
            elsif plan_duration == "annually"
                expiry_date = (DateTime.parse(@subscribe_date).next_year).strftime('%d-%m-%Y %H:%M:%S')
            end
            expiry_date
        end
    

        def get_subscription_plan_code
            @member.subscription_plan.paystack_plan_code
        end

        def create_general_transaction
            GeneralTransaction.create(
                member_fullname: @member.fullname,
                transaction_type: 0,
                subscribe_date: @subscribe_date,
                expiry_date: @expiry_date,
                staff_responsible: "Administrator",
                payment_method: retrieve_payment_method,
                loyalty_earned: get_loyalty_points,
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

