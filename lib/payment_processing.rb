module PaymentProcessing

    class Subscribe

        def initialize(options)
            @member = options[:member]
            @reference = options[:reference] ||= nil
            @paystack_key = options[:paystack_key] ||= nil
            @current_user = options[:staff_name]
            @subscribe_date = options[:subscribe_date] ||= nil
            @expiry_date = options[:expiry_date] ||= nil
            @subscription_status = options[:subscription_status] ||= nil
            @payment_method = options[:payment_method] ||= nil
            @amount = options[:amount] ||= nil
        end

        def verify_transaction
            begin
                uri = URI("https://api.paystack.co/transaction/verify/#{@reference}")
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = true
                http.verify_mode = OpenSSL::SSL::VERIFY_NONE
                req = Net::HTTP::Get.new(uri.path, {
                    'Authorization' => "Bearer #{@paystack_key}"
                })
                res = http.request(req)
                subscribe = JSON.parse(res.body)
            rescue => e
                puts "failed #{e}"
                Raven.capture_exception(e)
            end
        end

        def paystack_subscribe
            result = verify_transaction
            if result["status"] == true
                auth_code = (result["data"]["authorization"]["authorization_code"]).to_s
                paystack_customer_code = (result["data"]["customer"]["customer_code"]).to_s

                ## Decided not to use paystack start date because of the flexibility
                # of using manual start date at the point of registration
                start_date = set_paystack_next_charge_date
                plan_code  = get_subscription_plan_code
                payload = {
                    :customer => paystack_customer_code,
                    :plan => plan_code,
                    :authorization => auth_code,
                    :start_date => start_date,
                }
                subscribe = ''
                begin
                    uri = URI('https://api.paystack.co/subscription')
                    http = Net::HTTP.new(uri.host, uri.port)
                    http.use_ssl = true
                    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
                    req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json',
                                                         'Authorization' => "Bearer #{@paystack_key}" })
                    req.body = JSON.generate(payload)
                    res = http.request(req)
                    subscribe = JSON.parse(res.body)
                rescue => e
                    puts "failed #{e}"
                    Raven.capture_exception(e)
                end

                if subscribe["status"] == true
                    subscription_code = subscribe["data"]["subscription_code"].to_s
                    email_token = subscribe["data"]["email_token"].to_s
                    @member.update(paystack_subscription_code: subscription_code,
                                   paystack_email_token: email_token,
                                   paystack_auth_code: auth_code,
                                   paystack_cust_code: paystack_customer_code)
                    paystack_created_date = subscribe["data"]["createdAt"]
                    @subscribe_date = set_subscribe_date
                    @expiry_date = set_expiry_date
                    @payment_method = retrieve_payment_method
                    @amount = retrieve_amount
                    @subscription_status = 0
                    create_charge
                    account_update = update_account_detail
                    if account_update.save
                        update_subscription_histories
                        options = {"description": 'Subscription', "amount": @amount}
                        Accounting::Entry.new(options).card_entry
                    end
                    return 200
                else
                    return 500
                end
            else
                return 400
            end
        end

        def update_subscription_histories
            create_subscription_history
            create_loyalty_history
            create_general_transaction
            intiate_wallet_account if @member.wallet_detail.nil?
            create_attendance_record if @member.attendance_records.empty?
        end

        def get_subscription_plan_code
            @member.subscription_plan.paystack_plan_code
        end

        def set_subscribe_date
            ## Hack to set start date for renewals
            ## @member.account_detail.created_at < DateTime.now - 1.day
            ## set date to today's date if there is no history of subscription history
            if @member.subscription_histories.empty?
                date = DateTime.now
            else
                date = @member.account_detail.subscribe_date
            end
            return date
        end

        def set_expiry_date
            if @member.subscription_plan.duration == "daily"
                expiry_date =  (@subscribe_date + 1.day).strftime('%d-%m-%Y %H:%M:%S')
            elsif @member.subscription_plan.duration == "weekly"
                expiry_date =  (@subscribe_date + 7.days).strftime('%d-%m-%Y %H:%M:%S')
            elsif @member.subscription_plan.duration == "monthly"
                expiry_date =  (@subscribe_date + 30.days).strftime('%d-%m-%Y %H:%M:%S')
            elsif @member.subscription_plan.duration == "quarterly"
                expiry_date =  (@subscribe_date + 90.days).strftime('%d-%m-%Y %H:%M:%S')
            elsif @member.subscription_plan.duration == "annually"
                expiry_date =  (@subscribe_date.next_year).strftime('%d-%m-%Y %H:%M:%S')
            end
            expiry_date
        end

        # method to set the next start date Paystack should charge a customer
        def set_paystack_next_charge_date
            if @member.account_detail.created_at.to_date < Date.today - 1.day
                date = DateTime.now
            else
                date = @member.account_detail.subscribe_date
            end
            if @member.subscription_plan.duration == "weekly"
                start_date = date.next_week.strftime('%FT%T%:z').to_s
            elsif @member.subscription_plan.duration == "monthly"
                start_date = date.next_month.strftime('%FT%T%:z').to_s
            elsif @member.subscription_plan.duration == "quarterly"
                start_date = (date + 90.days).strftime('%FT%T%:z').to_s
            elsif @member.subscription_plan.duration == "annually"
                start_date = date.next_year.strftime('%FT%T%:z').to_s
            end
            return start_date
        end



        private

        def create_charge
            charge = @member.charges.new(service_plan: retrieve_gym_plan,
                                         amount: retrieve_amount,
                                         payment_method: retrieve_payment_method,
                                         duration: @member.subscription_plan.duration,
                                         gofit_transaction_id: SecureRandom.hex(4)
            )
            if charge.save
                MemberMailer.new_subscription(@member).deliver_later
            end

        end

        def retrieve_gym_plan
            plan = @member.subscription_plan.plan_name
        end

        def retrieve_payment_method
            @member.payment_method.payment_system
        end

        def intiate_wallet_account
            wallet_update  = @member.build_wallet_detail(
                current_balance: 0,
                total_amount_funded: 0,
                amount_last_funded: 0,
                total_amount_used: 0,
                wallet_status: 1,
                wallet_expiry_date: DateTime.now,
                audit_comment: "New wallet account created"
            )
            wallet_update.save
        end


        def update_account_detail
            account_update = @member.build_account_detail(
                                        subscribe_date: @subscribe_date,
                                        expiry_date: @expiry_date,
                                        member_status: 0,
                                        amount: @amount,
                                        loyalty_points_balance: get_loyalty_points,
                                        loyalty_points_used: 0,
                                        gym_plan: retrieve_gym_plan,
                                        recurring_billing: true,
                                        gym_attendance_status: 1,
                                        audit_comment: "paid for membership plan" )
        end


        def create_subscription_history
            subscription_history = @member.subscription_histories.create(
                subscribe_date: @subscribe_date,
                expiry_date: @expiry_date,
                subscription_type: 0,
                subscription_plan: retrieve_gym_plan,
                amount: retrieve_amount,
                payment_method: retrieve_payment_method,
                member_status: 0,
                subscription_status: @subscription_status
            )
        end

        def create_loyalty_history
            points = get_loyalty_points
            loyalty_history = @member.loyalty_histories.create(
                points_earned: points,
                points_redeemed: 0,
                loyalty_transaction_type: 0,
                loyalty_balance: points,
                )
        end

        def get_loyalty_points
            point = Loyalty.find_by(loyalty_type: "register").loyalty_points_percentage ||= 15
            point = ((point * 0.01) * @amount).to_i
        end

        def create_general_transaction
            GeneralTransaction.create(
                member_fullname: @member.fullname,
                transaction_type: 0,
                subscribe_date: @subscribe_date,
                expiry_date: set_expiry_date,
                staff_responsible: @current_user.fullname,
                payment_method: @payment_method,
                loyalty_earned: get_loyalty_points,
                loyalty_redeemed: 0,
                membership_plan: retrieve_gym_plan,
                membership_status: 0,
                customer_code: @member.customer_code,
                member_email: @member.email,
                loyalty_type: 0,
                amount: @amount )
        end

        def create_attendance_record
            @member.attendance_records.create(
                checkin_date: DateTime.now,
                checkout_date: nil,
                membership_status: @member.account_detail.member_status,
                membership_plan: @member.subscription_plan.plan_name,
                staff_on_duty: @current_user.fullname,
                audit_comment: "checked into the gym" )
        end

        def retrieve_amount
            amount = @member.subscription_plan.cost
        end

        def retrieve_payment_method
            @member.payment_method.payment_system
        end

    end
end