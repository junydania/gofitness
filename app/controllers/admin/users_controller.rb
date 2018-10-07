class Admin::UsersController < Devise::RegistrationsController
    
    load_and_authorize_resource param_method: :sign_up_params
    
    prepend_before_action :require_no_authentication, :only => [ :cancel]


    def index
        @users = User.all
    end

    def show
        @user = User.find(params[:id])
    end


    def new 
     super
    end

    def create
        build_resource(sign_up_params)
        if resource.save
          resource.audits
          redirect_to new_user_registration_path
          flash[:notice] = "User successfully created"
        else
          clean_up_passwords resource
          respond_with resource
        end
        resource.audits.last.user
    end

    def edit
        @user = User.find(params[:id])
    end

    def change_role
      @user = User.find(params[:id])
    end

    def update_role
      if @user.update(update_without_password_params)
        redirect_to user_profile_path(current_user)
        flash[:notice] = "User role successfully updated"     
      else
        render :change_role
      end
    end

    def update
        if update_without_password_params[:password].blank?
          resource_updated = resource.update_without_password(update_without_password_params)
          if resource_updated
            redirect_to users_path
            flash[:notice] = "Account successfully updated"
          else
            render :edit
          end
        elsif !update_with_password_params[:password].blank?
          resource_updated = User.update(update_without_password_params)
          if resource_updated
            bypass_sign_in(resource)
            redirect_to users_path
            flash[:notice] = "Account successfully updated"
          else
            flash[:error] = "Failed to Update record"
            render :edit
          end
        else
          render :edit
        end
      end

      def staff_tracking
        @user = User.new
        @users = User.all
      end



    private

    def sign_up_params
        params.require(:user)
            .permit(
                    :email,
                    :password,
                    :password_confirmation,
                    :first_name,
                    :last_name,
                    :role
            )
    end

    def update_without_password_params
        params.require(:user)
              .permit(
                    :email,
                    :first_name,
                    :last_name,
                    :password,
                    :password_confirmation,
                    :role
                   )
    end
    
    def update_with_password_params
      params.require(:user)
            .permit(
                    :email,
                    :password,
                    :password_confirmation,
                    :first_name,
                    :last_name,
                    :current_password,
                    :role
            )
    end
      


end
