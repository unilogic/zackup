# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  helper_method :current_user_session, :current_user, :settings, :the_key
  
  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation, :_confirmation
  
  
  private
  
    def the_key
      # Please CHNAGE the "key", and "salt" values below!! 
      # Feel free to use "rake secret" to generate some really long values. 
      #
      # NOTE: Because this is using 2-way encryption and the password and salt are stored RIGHT here
      #       this is not a super secure way of storing data. It's main purpose is to keep passwords from
      #       being stored in plaintext in the database, yet allow other parts of the software to still use the passwords. 
      #       If someone can read this file they can easily create a way to unencrypt passwords.
      #       YOU HAVE BEEN WARNED!!!
      key = '85bb751ee853a388be42c0579822bc75e258bbfbffefbbb012af48f3c7ce70567742d6a804a87142748e68c599c1740cfdcf80cdda8fdab8c11b299469e42803'
      salt = '5990acbe43a061f06a3da020478f5d342cc3616319c86ae71d80fd3d6eea891293d19c683008fa3837fd704d4a0c68355b76f907a4552f1c92e6f2b7bd1b5734'
      @theKey ||= EzCrypto::Key.with_password(key, salt)
    end
    
    def settings
      @settings ||= Setting.default
    end
    
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end
    
    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end
    
    def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to account_url
        return false
      end
    end
    
    def store_location
      session[:return_to] = request.request_uri
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
     
end
