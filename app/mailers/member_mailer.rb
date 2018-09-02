class MemberMailer < ApplicationMailer

    default from: 'customerservice@gofitnessng.com'

    def welcome_email(member)
        attachments.inline["gofitness_dashboard.png"] = File.read("#{Rails.root}/app/assets/images/gofitness_dashboard.png")
        @member = member
        @url  = 'http://www.gofitnessng.com'
        mail(to: @member.email, subject: 'Welcome to Gofitness Gym')
    end

    def new_subscription(member)
        attachments.inline["gofitness_dashboard.png"] = File.read("#{Rails.root}/app/assets/images/gofitness_dashboard.png")
        @member = member
        @url  = 'http://www.gofitnessng.com'
        mail(to: @member.email, subject: 'New Membership Invoice')
    end

    def renewal(member)
        attachments.inline["gofitness_dashboard.png"] = File.read("#{Rails.root}/app/assets/images/gofitness_dashboard.png")
        @member = member
        @url  = 'http://www.gofitnessng.com'
        mail(to: @member.email, subject: 'Membership Renewal Invoice')
    end

    def wallet_funding(member)
        attachments.inline["gofitness_dashboard.png"] = File.read("#{Rails.root}/app/assets/images/gofitness_dashboard.png")
        @member = member
        @url  = 'http://www.gofitnessng.com'
        mail(to: @member.email, subject: 'Wallet Funding Invoice')
    end

end

