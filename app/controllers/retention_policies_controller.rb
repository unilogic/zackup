class RetentionPoliciesController < ApplicationController
  def edit
    @schedule = Schedule.find(params[:schedule_id])
    @host = Host.find(params[:host_id])
    unless @retention_policy = @schedule.retention_policy
      @retention_policy = RetentionPolicy.new
    end
  end
  
  def create
    @retention_policy = RetentionPolicy.new(params[:retention_policy])
    
    if @retention_policy.save
      flash[:notice] = "Retention policy created!"
      redirect_to host_schedules_path(params[:host_id])
    else
      @host = Host.find(params[:host_id])
      @schedule = Schedule.find(params[:schedule_id])
      render :action => :edit
    end
  end
  
  def update
    @retention_policy = RetentionPolicy.find_by_schedule_id(params[:retention_policy][:schedule_id])
    if @retention_policy.update_attributes(params[:retention_policy])
      flash[:notice] = "Retention policy updated!"
      redirect_to host_schedules_path(params[:host_id])
    else
      @host = Host.find(params[:host_id])
      @schedule = Schedule.find(params[:schedule_id])
      render :action => :edit
    end
  end
end
