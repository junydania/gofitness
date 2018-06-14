class Admin::MemberStepsController < ApplicationController
    
    include Wicked::Wizard

    steps :payment, :personal_profile, :next_of_kin

    def show
        member_id = session[:member_id]
        @member = Member.find(member_id)
        render_wizard
    end

end
