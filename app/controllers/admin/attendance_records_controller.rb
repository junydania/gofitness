class Admin::AttendanceRecordsController < ApplicationController
    before_action :authenticate_user!
    before_action :find_member, only: [:member_check_in, :create_attendance_record]


    def index
        @members = Member.all
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
