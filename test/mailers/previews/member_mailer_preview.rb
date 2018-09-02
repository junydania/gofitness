class MemberMailerPreview < ActionMailer::Preview
    def welcome_email
        MemberMailer.welcome_email(member)
    end
end