class WelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(*args)
   
  end

  def perform_later
  end

end

WelcomeEmailJob.perform_now current_user
