class Admin::LoyaltiesController < ApplicationController
    
    before_action :authenticate_user!
    before_action :find_loyalty_plan, only: [:show, :edit, :update, :destroy] 

    def index
        @loyalties = Loyalty.all
        @loyalty= Loyalty.new
    end

    def create
        binding.pry
        @new_loyalty = Loyalty.new(loyalty_param)
        if @new_loyalty.save
            flash[:notice] = "Loyalty Plan Successfully Created"
            redirect_to admin_loyalties_path
        else
            redirect_to admin_loyalties_path
        end
    end

    def edit
      @loyalty  
      respond_to do |format|
        format.js
      end
    end


    def update
        respond_to do |format|
            if @loyalty.update_attributes(loyalty_param)
                format.js { render action: 'index', status: :updated }
            else
                format.json { render json: @loyalty.errors, status: :unprocessable_entity }
            end
        end        
    end

    def destroy
        @loyalty.destroy
        redirect_to admin_loyalties_path
    end
    

    private

    def loyalty_param
        params.require(:loyalty) 
            .permit(:loyalty_type, :loyalty_points_percentage)
    end

    def find_loyalty_plan
        @loyalty = Loyalty.find(params[:id])
    end


end
