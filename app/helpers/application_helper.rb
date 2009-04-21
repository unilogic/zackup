# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def is_dashboard?
    if controller.controller_name == 'dashboard'
      "current"
    end
  end
  
  def is_hosts?
    if controller.controller_name == 'hosts'
      "current"
    end
  end
  
  def is_account?
    if controller.controller_name == 'users'
      "current"
    end
  end
  
  def is_login_form?
    if controller.controller_name == 'user_sessions' && controller.action_name == 'new'
      "current"
    end
  end
  
  def is_register_form?
    if controller.controller_name == 'users' && controller.action_name == 'new'
      "current"
    end
  end
end
