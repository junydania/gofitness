class Admin::HistoricalsController < ApplicationController

    before_action :find_member, only: [:subscription_history, 
                                        :loyalty_history, 
                                        :wallet_history, 
                                        :attendance_history, 
                                    ]

    def subscription_history
        @subscription_history_activities = @member.subscription_histories
    end

    def loyalty_history
        @loyalty_history_activities = @member.loyalty_histories
    end

    def wallet_history
        @wallet_history_activities = @member.wallet_histories
    end

    def attendance_history
        @attendance_history_activities = @member.attendance_records
    end


    def find_member
        @member = Member.find(params[:id]) 
    end
  

end
