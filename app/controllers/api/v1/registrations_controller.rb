class Api::V1::RegistrationsController < Devise::RegistrationsController

    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :null_session

    respond_to :json
    skip_before_filter :verify_authenticity_token, if: :json_request?
    
    acts_as_token_authentication_handler_for User, only: [:destroy], fallback: :exception
    
    # Без этих двух строк не работает destroy, пишет not working error: You need to sign in
    skip_before_filter :authenticate_scope!
    append_before_filter :authenticate_scope!, only: [:destroy]
    
    def create
        build_resource(sign_up_params)
        resource.skip_confirmation!
        
        if resource.save
            sign_in resource
            render :status => 200,
            :json => {
                :success => true,
                :info => "Registered",
                :data => {
                    :user => resource,
                    :auth_token => current_user.authentication_token
                }
            }
        else
            render :status => :unprocessable_entity,
            :json => {
                :success => false,
                :info => resource.errors,
                :data => {}
            }
        end

    end
    
    def destroy
        if user_signed_in?
            resource.destroy
            Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
            render :status => 200,
            :json => {
                :success => true,
                :info => "Yor account has been deleted",
                :data => {}
            }
        else
            render :status => 401,
            :json => {
                :success => false,
                :info => "Failed to delete account. User must be logged in.",
                :data => {}
            }
        end
    end
    
    private
    def json_request?
        request.format.json?
    end
    
    def sign_up_params
        params.require(:user).permit(:phone, :password, :password_confirmation)
    end
end