class Admin::OneOffRevenuesController < ApplicationController

    load_and_authorize_resource param_method: :one_off_params

    before_action :authenticate_user!
    before_action :find_one_off_cost, only: [:show, :edit, :update]

    def index
        @one_off_revenues = OneOffRevenue.all
        @one_off = OneOffRevenue.new
    end

    def create
        @new_one_off_cost = OneOffRevenue.new(one_off_params)
        if @new_one_off_cost.save
            flash[:notice] = "One Off Cost Successfully Created"
            redirect_to admin_one_off_revenues_path
        else
            redirect_to admin_one_off_revenues_path
        end
    end

    def edit
      @one_off
      respond_to do |format|
        format.js
      end
    end


    def update
        respond_to do |format|
            if @one_off.update_attributes(one_off_params)
                format.js { render action: 'index', status: :updated }
            else
                format.json { render json: @one_off.errors, status: :unprocessable_entity }
            end
        end        
    end


    private

    def one_off_params
        params.require(:one_off_revenue)
            .permit(:cost_type, :amount)
    end

    def find_one_off_cost
        @one_off = OneOffRevenue.find(params[:id])
    end

end
