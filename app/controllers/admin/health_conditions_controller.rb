class Admin::HealthConditionsController < ApplicationController
    load_and_authorize_resource param_method: :health_param

    before_action :authenticate_user!
    
    def create
        @health_condition = HealthCondition.new(health_param)
        if @health_condition.save
          render json: @health_condition
        else
          render json: {errors: @health_condition.errors.full_messages}
        end
    end
    
    private

    def health_param
        params.require(:health_condition).permit(:condition_name)
    end

end
