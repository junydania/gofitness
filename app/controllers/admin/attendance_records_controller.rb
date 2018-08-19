class Admin::AttendanceRecordsController < ApplicationController
    
    before_action :authenticate_user!
    before_action :find_member, only: [:member_check_in, :create_attendance_record]


    def index
        @filterrific = initialize_filterrific(
          Member.with_account_details,
            params[:filterrific],
            select_options: {
              with_subscription_plan_id: SubscriptionPlan.options_for_select,
              with_fitness_goal_id: FitnessGoal.options_for_select,
              with_payment_method_id: PaymentMethod.options_for_select,
              sorted_by: Member.options_for_sorted_by
            },
            persistence_id: 'shared_key',
            default_filter_params: {},
        ) or return
        @members = @filterrific.find.page(params[:page])
            
        respond_to do |format|
          format.html
          format.js
        end
    
        rescue ActiveRecord::RecordNotFound => e
          puts "Had to reset filterrific params: #{ e.message }"
          redirect_to(reset_filterrific_url(format: :html)) && return
      end


    def member_check_in
        if @member.account_detail.gym_attendance_status != 'checkedin'
            if @member.account_detail.member_status == 'active'
                create_attendance_record
                @member.account_detail.gym_attendance_status = 1
                @member.save
                render status: 200, json: {
                    message: "success"
                }
            else
                render status: 200, json: {
                    message: "failed"
                }
            end
        else 
            render status: 200, json: {
                message: "checkedin"
            }
        end
    end



    private

    def find_member
        @member = Member.find(params[:id]) 
    end


    def create_attendance_record
        @member.attendance_records.create(
            checkin_date: DateTime.now,
            checkout_date: nil,
            membership_status: @member.account_detail.member_status,
            membership_plan: @member.subscription_plan.plan_name,
            staff_on_duty: current_user.fullname )
    end

end
