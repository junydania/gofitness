Given("the following user account exist") do |table|
    table.hashes.each do |hash|
        FactoryBot.create(:user, hash)
    end
end
  
Given("I visit the {string} page") do |sign_in|
    visit("/users/#{sign_in}")
end

Given("I fill in field {string} with {string}") do |email, password|
    fill_in email, with: password
end
  
Given("I click on {string}") do |login|
    click_link_or_button(login)
end
  
Given("I should see {string}") do |string|
    expect(page).to have_content(string)
end

Then(/^show page$/) do
    save_and_open_page
end


def check_email(email, negate, subject, body = nil)
    unless negate
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(ActionMailer::Base.deliveries[0].subject).to include(subject)
      expect(ActionMailer::Base.deliveries[0].body).to include(body) unless body.nil?
      expect(ActionMailer::Base.deliveries[0].to).to include(email) unless email.nil?
    else
      expect(ActionMailer::Base.deliveries.size).to eq 0
    end
end

Given("I should receive a {string} email") do |subject|
    expect(ActionMailer::Base.deliveries.size).to eq 1
    expect(ActionMailer::Base.deliveries[0].subject).to include(subject)
end
  
When("I click on the retrieve password link in the last email") do
    password_reset_link = ActionMailer::Base.deliveries.last.body.match(
        /<a href=\"(.+)\">Change my password<\/a>/
    )[1]
    visit password_reset_link
end
  
Then("I fill in {string} with {string}") do |new_password, password|
    fill_in new_password, with: password
end

Given("I select {string} from {string}") do |choice, options|
    select(choice, from: options)
end