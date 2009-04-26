# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def is_dashboard?
    if controller.controller_name == 'dashboard'
      "current"
    end
  end
  
  def is_hosts?
    if controller.controller_name == 'hosts' || controller.controller_name == 'config_items'
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
  
  def display_types
    return {  'Text Field'      => 'text_field',
              'Password Field'  => 'password_field',
              'Text Area'       => 'text_area',
              'Check Box'       => 'check_box',
              'File Field'      => 'file_field',
              'Hidden Field'    => 'hidden_field',
              'Radio Button'    => 'radio_button' }
  end
  
  def display_types_rev
    return {  'text_field'      => 'Text Field',
              'password_field'  => 'Password Field',
              'text_area'       => 'Text Area',
              'check_box'       => 'Check Box',
              'file_field'      => 'File Field',
              'hidden_field'    => 'Hidden Field',
              'radio_button'    => 'Radio Button' }
  end

end
