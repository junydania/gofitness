class DeveloperTestMailer < ApplicationMailer

    def send_test_email(user)
        attachments.inline["gofitness_dashboard.png"] = File.read("#{Rails.root}/app/assets/images/gofitness_dashboard.png")
        @user = user
        @url  = 'http://www.gofitnessng.com'
        mail(to: @user.email, subject: 'Test Mail from Gofitness')
    end
end
