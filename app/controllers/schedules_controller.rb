class SchedulesController < ApplicationController
  before_filter :require_user
  
  def index
    @host = Host.find(params[:host_id])
    @schedules = Schedule.find_all_by_host_id(params[:host_id])
  end
  
  def new
    @schedule = Schedule.new
    @host = Host.find(params[:host_id])
    @date = Date.today
    @time = Time.current
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
    
    unless @schedule.status
      @schedule.status = 'new'
    end
    
    if @schedule.save
      flash[:notice] = "Schedule created!"
      redirect_to host_schedules_path(params[:host_id])
    else
      @host = Host.find(params[:host_id])
      render :action => :new
    end
  end
  
  def edit
    @host = Host.find(params[:host_id])
    @schedule = Schedule.find(params[:id])
    @time = Time.parse(@schedule.start_time)
    @date = @schedule.start_date
    @repeat_type = @schedule.repeat
    
    if @repeat_type == 'weekly'
      @set_days = YAML::load(@schedule.on)
    end
  end
  
  def update
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
    
    @schedule = Schedule.find(params[:id])
    if @schedule.update_attributes(params[:schedule])
      flash[:notice] = "Schedule updated!"
      redirect_to host_schedules_path(params[:host_id])
    else
      @host = Host.find(params[:host_id])
      render :action => :edit
    end  
    
  end
  
  def destroy
    @schedule = Schedule.find(params[:id])
    if request.delete?
      @schedule.destroy
      flash[:notice] = "Schedule deleted!"
    end
    respond_to do |format|
      format.html { redirect_to host_schedules_path(params[:host_id]) }
      format.xml  { head :ok }
    end
  end
  
  def get_on_form
    @repeat_type = params[:type]
    respond_to do |format|
      format.js { render :partial => 'get_on_form' }
    end
  end
  
  def disable
    @schedule = Schedule.find(params[:id])
    
    if @schedule.update_attributes( :status => 'disabled' )
      flash[:notice] = "Schedule disabled!"
      redirect_to host_schedules_path(params[:host_id])
    else
      render :action => :index
    end
  end
  
  def enable
    @schedule = Schedule.find(params[:id])
    
    if @schedule.update_attributes( :status => 'enabled' )
      flash[:notice] = "Schedule enabled!"
      redirect_to host_schedules_path(params[:host_id])
    else
      render :action => :index
    end
  end
end
