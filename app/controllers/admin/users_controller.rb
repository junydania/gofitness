class Admin::UsersController < Devise::RegistrationsController

    # load_and_authorize_resource param_method: :sign_up_params, find_by: :slug
    prepend_before_action :require_no_authentication, :only => [ :cancel]


    def new 
     super
    end

    def create
        build_resource(sign_up_params)
        if resource.save
          redirect_to new_user_registration_path
          flash[:notice] = "User successfully created"
        else
          clean_up_passwords resource
          respond_with resource
        end
    end



    private

    def sign_up_params
        params.require(:user)
            .permit(:email,
                    :password,
                    :password_confirmation,
                    :first_name,
                    :last_name
            )
    end


end
