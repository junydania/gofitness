class Admin::FitnessGoalsController < ApplicationController

    before_action :find_fitness_goal, only: [:show, :edit, :update, :destroy] 

    def index
        @goals = FitnessGoal.all
        @fitness_goal = FitnessGoal.new
    end

    def create
        @new_goal = FitnessGoal.new(goal_param)
        if @new_goal.save
            flash[:notice] = "New Goal Successfully Created"
            redirect_to admin_fitness_goals_path
        else
            redirect_to admin_fitness_goals_path
        end
    end

    def edit
      @goal
      respond_to do |format|
        format.js
      end
    end


    def update
        @goal
        respond_to do |format|
            if @goal.update_attributes(goal_param)
                format.js { render action: 'index', status: :updated }
            else
                format.json { render json: @goal.errors, status: :unprocessable_entity }
            end
        end        
    end

    def destroy
        @goal.destroy
        redirect_to admin_fitness_goals_path
    end
    

    private

    def goal_param
        params.require(:fitness_goal) 
            .permit(:goal_name)
    end

    def find_fitness_goal
        @goal = FitnessGoal.find(params[:id])
    end

end
