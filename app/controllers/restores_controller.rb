class RestoresController < ApplicationController
  
  def index
    @host = Host.find(params[:host_id])
    @restores = @host.restores
  end
  
  def show
    @host = Host.find(params[:host_id])
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
    
    file_indices = FileIndex.find_all_by_host_id_and_schedule_id(params[:host_id], params[:schedule][:schedule_id], :select => "id,snapname")
    if file_indices.length > 0 && @restore.save!
      redirect_to host_restore_schedule_file_indices_path(params[:host_id], @restore.id, params[:schedule][:schedule_id])
    else
      flash[:error] = "Problem creating the restore. Either there are no snapshots for this host and schedule or there was a problem with the database!"
      @host = Host.find(params[:host_id])
      @restore = Restore.new
      @schedules = @host.schedules
      render :action => :new
    end
  end
  
  def destroy
    @restore = Restore.find(params[:id])
    if request.delete?
      flash[:notice] = "Restore deleted!"
      @restore.destroy
    end

    redirect_to host_restores_path(params[:host_id])

  end
end
