module WelcomeHelper

    def fetch_revenue_today
        revenue_today =  $redis.get("revenue_today")
        if revenue_today.nil?
            revenue = Plutus::Revenue.find_by_name("Sales Revenue")
            revenue = revenue.balance(:from_date => DateTime.now.beginning_of_day, :to_date => DateTime.now)
            revenue_today = revenue.to_i.to_json
            $redis.set("revenue_today", revenue_today)
            $redis.expire("revenue_today",1.hour.to_i)
        end
        JSON.load revenue_today
    end

    def fetch_revenue_month
        revenue_month =  $redis.get("revenue_month")
        if revenue_month.nil?
            revenue = Plutus::Revenue.find_by_name("Sales Revenue")
            revenue = revenue.balance(:from_date => DateTime.now.beginning_of_month, :to_date => DateTime.now)
            revenue_month = revenue.to_i.to_json
            $redis.set("revenue_month", revenue_month)
            $redis.expire("revenue_month",1.hour.to_i)
        end
        JSON.load revenue_month
    end

    def total_customers
        total_customers=  $redis.get("total_customers")
        if total_customers.nil?
            total_customers = Member.all.count.to_json
            $redis.set("total_customers", total_customers)
            $redis.expire("total_customers",1.hour.to_i)
        end
        JSON.load total_customers
    end

    def active_customers
        active_customers=  $redis.get("active_customers")
        if active_customers.nil?
            active_customers = Member.joins(:account_detail).where(account_details: {member_status: 0}).count.to_json
            $redis.set("active_customers", active_customers)
            $redis.expire("active_customers",1.hour.to_i)
        end
        JSON.load active_customers
    end

    def inactive_customers
        inactive_customers=  $redis.get("inactive_customers")
        if inactive_customers.nil?
            inactive_customers = Member.joins(:account_detail).where(account_details: {member_status: 1}).count.to_json
            $redis.set("inactive_customers", inactive_customers)
            $redis.expire("active_customers",1.hour.to_i)
        end
        JSON.load inactive_customers
    end

    def earnings_chart
        # (Date.today.beginning_of_year.to_date..Date.today).map do |date|
        #     {
        #         created_at: date,
                
        #     }
            
        # end
    end

end

