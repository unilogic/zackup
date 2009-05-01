class SchedulesController < ApplicationController
  def index
    
  end
  def new
    @schedule = Schedule.new
    @host = Host.find(params[:host_id])
  end
  
  def create
    if params[:schedule][:hour] && params[:schedule][:minute]
      params[:schedule][:start_time] = "#{params[:schedule][:hour]}:#{params[:schedule][:minute]}"
      params[:schedule].delete(:hour)
      params[:schedule].delete(:minute)
    end
    
    
    if params[:schedule][:repeat] == 'weekly' && ! params[:schedule][:on]
      days = []
      Date::DAYNAMES.each { |day|
        if params[:schedule][day] == "true"
          days.push(day)
        end
        params[:schedule].delete(day)
      }
      params[:schedule][:on] = days.to_yaml
    end
    
    
    @schedule = Schedule.new(params[:schedule])
    
    if @schedule.save
      flash[:notice] = "Schedule created!"
      redirect_to edit_host_path(params[:host_id])
    else
      render :action => :new
    end
  end
  
  def get_on_form
    @repeat_type = params[:type]
    respond_to do |format|
      format.js { render :partial => 'get_on_form' }
    end
  end
  
end
