class RestoresController < ApplicationController
  
  def index
    @host = Host.find(params[:host_id])
    @restores = @host.restores
  end
  
  def show
    @restore = Restore.find(params[:id])
  end
  
  def new
    @host = Host.find(params[:host_id])
    @restore = Restore.new
    @schedules = @host.schedules
  end
  
  def create
    @restore = Restore.new(params[:restore])
    @restore.host_id = params[:host_id]
    @restore.schedule_id = params[:schedule][:schedule_id]
    
    if @restore.save!
      redirect_to host_restore_schedule_file_indices_path(params[:host_id], @restore.id, params[:schedule][:schedule_id])
    else
      @host = Host.find(params[:host_id])
      render :action => :new
    end
  end
  
end
