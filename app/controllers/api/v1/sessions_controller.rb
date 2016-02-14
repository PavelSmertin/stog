
        class Api::V1::SessionsController < Devise::SessionsController
            
            # Prevent CSRF attacks by raising an exception.
            # For APIs, you may want to use :null_session instead.
            #protect_from_forgery with: :null_session
            
            acts_as_token_authentication_handler_for User, only: [:destroy], fallback: :exception
            
            skip_before_filter :verify_authenticity_token, if: :json_request?
            skip_before_filter :verify_signed_out_user, only: :destroy
           
            def create
                warden.authenticate!(:scope => resource_name)
                render :status => 200,
                :json => { :success => true,
                    :info => "Logged in",
                    :data => {
                        :auth_token => current_user.authentication_token
                    }
                }
            end
            
            def destroy
                if user_signed_in?
                    current_user.update authentication_token: nil
                    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
                    render :status => 200,
                    :json => { :success => true,
                        :info => "Logged out",
                        :data => {} }
                else
                render :status => 401,
                :json => { :success => false,
                    :info => "Failed to log out. User must be logged in.",
                    :data => {} }
                end

            end
            
            def json_request?
                request.format.json?
            end

        end

