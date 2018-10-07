class Admin::DeveloperTestController < ApplicationController


    def get_mail_form
        @user = current_user
        render
    end

    def send_mail
        @user = current_user
        @user.email = test_params["email"]
        DeveloperTestMailer.send_test_email(@user).deliver_now
    end


    def test_params
        params.require(:user)
            .permit( :id,
                    :email,
                    :first_name,
                    :last_name )
    end

end
