class WelcomeController < ApplicationController

  include WelcomeHelper

  before_action :authenticate_user!
  
  def index
    @revenue_today = fetch_revenue_today
    @revenue_month = fetch_revenue_month
    @total_customers = total_customers
    @active_customers = active_customers
    @inactive_customers = inactive_customers
    @registration_earnings = SubscriptionHistory.where(subscription_type: 'registration')
  end

  
 
end

