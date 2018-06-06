class Admin::FeaturesController < ApplicationController

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
