class RestoresController < ApplicationController
  
  def index
    @host = Host.find(params[:host_id])
    @restores = Restore.find_all_by_host_id(params[:host_id])
  end
  
  def show
    @restore = Restore.find(params[:id])
  end
  
  def new
    @host = Host.find(params[:host_id])
    @restore = Restore.new(:host_id => params[:host_id])
    @schedules = @host.schedules
  end
  
  def create
    @restore = Restore.new(params[:restore])
    
    if @restore.save!
      redirect_to host_restore_schedule_file_indices_path(params[:host_id], @restore.id, params[:schedule][:schedule_id])
    else
      @host = Host.find(params[:host_id])
      render :action => :new
    end
  end
  
end
