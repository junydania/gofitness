class Admin::HistoricalsController < ApplicationController

    before_action :find_member, only: [:subscription_history, 
                                        :loyalty_history, 
                                        :wallet_history, 
                                        :attendance_history, 

                                    ]

    def subscription_history
    end

    def loyalty_history
    end

    def wallet_history
    end

    def attendance_history
    end


    def find_member
        @member = Member.find(params[:id]) 
    end
  

end
