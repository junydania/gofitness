class ApplicationController < ActionController::Base
  
  protect_from_forgery with: :exception

  layout :layout_by_resource

  before_action :authenticate_user!, :configure_permitted_parameters, if: :devise_controller?
  before_action :set_raven_context


  def after_sign_out_path_for(resource)
    new_user_session_path
  end

  def after_sign_in_path_for(resource)
    flash[:notice] = "Signed in successfully."
    admin_attendance_records_path
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { redirect_to main_app.root_url, notice: exception.message }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
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

  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

end
