class Admin::FeaturesController < ApplicationController

    load_and_authorize_resource param_method: :feature_params
    
    before_action :authenticate_user!

    def create
        @feature = Feature.new(feature_params)
        if @feature.save
          render json: @feature
        else
          render json: {errors: @feature.errors.full_messages}
        end
    end
    
    private

    def feature_params
        params.require(:feature).permit(:name, :description)
    end

end
