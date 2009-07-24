#include Scheduler

class SettingsController < ApplicationController
  # View form of settings
  def index
    
  end

  # Update the settings
  def update
    respond_to do |format|
      if settings.update_attributes(params[:setting])
        #Rooster::ControlClient.send_command('restart ParseSchedulesTask')
        flash[:notice] = 'Settings were successfully updated.'
        format.html { redirect_to settings_path }
      else
        format.html { render :action => "index" }
      end
    end
  end
  
  private
  

end
