class ApplicationController < ActionController::Base
  
  protect_from_forgery with: :exception

  layout :layout_by_resource

  before_action :authenticate_user!, :configure_permitted_parameters, if: :devise_controller?


  def after_sign_out_path_for(resource)
    new_user_session_path
  end

  def after_sign_in_path_for(resource)
    flash[:notice] = "Signed in successfully."
    root_path
  end

  
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end


  def layout_by_resource
    if devise_controller? && resource_name == :user && controller_name == 'sessions' && action_name == "new"
      "layout_blank"
    elsif devise_controller? && resource_name == :user && controller_name == 'passwords'
      "layout_blank"
    elsif devise_controller? and user_signed_in?
      "application"
    else
      "application"
    end
  end

end
