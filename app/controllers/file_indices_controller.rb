class FileIndicesController < ApplicationController
  
  def index
    @host_id = params[:host_id]
    @schedule_id = params[:schedule_id]
    @restore_id = params[:restore_id]
    @file_indices = FileIndex.find_all_by_host_id_and_schedule_id(params[:host_id], params[:schedule_id], :select => "id,snapname", :order => 'created_at DESC')
  end
  
  def get_file_index
    redirect_to host_restore_schedule_file_index_path(params[:host_id], params[:restore_id], params[:schedule_id], params[:file_index][:id])
  end
  
  def show
    @host_id = params[:host_id]
    @schedule_id = params[:schedule_id]

    @file_index = FileIndex.find(params[:id])
    @file_indices = FileIndex.find_all_by_host_id_and_schedule_id(params[:host_id], params[:schedule_id], :select => "id,snapname", :order => 'created_at DESC')
    @restore = Restore.find(params[:restore_id])
    
    @current_dir = params[:dir] || ""
    @current_dir.gsub!(/^\/*/, "/")
    
    @dirs_files = @file_index.get_content(@current_dir)
  end
  
  def add

    current_dir = params[:dir]
    add_item = params[:item]
    
    #Strip off slash, so we don't end up with double slash below.
    if current_dir == "/"
      current_dir = ""
    end
    
    @file_index = FileIndex.find(params[:id], :select => "id,snapname")
    @restore = Restore.find(params[:restore_id])
    
    if @restore.data
      unless @restore.data.include?({@file_index.snapname => "#{current_dir}/#{add_item}"})
        @restore.data << {@file_index.snapname => "#{current_dir}/#{add_item}"}
      end
    else
      @restore.data = [{@file_index.snapname => "#{current_dir}/#{add_item}"}]
    end
    
    if @restore.save!
      flash[:notice] = "#{add_item} has been added to the restore!"
      redirect_to host_restore_schedule_file_index_path(params[:host_id], params[:restore_id], params[:schedule_id], params[:id], :dir => current_dir)
    else
      flash[:error] = "Could not add #{add_item} to the restore!"
      redirect_to host_restore_schedule_file_index_path(params[:host_id], params[:restore_id], params[:schedule_id], params[:id], :dir => current_dir)
    end
    
  end
  
  def remove
    current_dir = params[:dir]
    item = params[:item]
    snapname = params[:snapname]
    
    @restore = Restore.find(params[:restore_id])
    
    if @restore.data && @restore.data.delete({snapname => item}) && @restore.save!
      flash[:notice] = "#{item} was delete from the restore!"
      redirect_to host_restore_schedule_file_index_path(params[:host_id], params[:restore_id], params[:schedule_id], params[:id], :dir => current_dir)
    else
      flash[:error] = "Could not delete #{item} from the restore!"
      redirect_to host_restore_schedule_file_index_path(params[:host_id], params[:restore_id], params[:schedule_id], params[:id], :dir => current_dir)
    end
  end
  
  def finish
    restore = Restore.find(params[:restore_id])
    schedule = Schedule.find(params[:schedule_id])
    host = Host.find(params[:host_id])
    
    @job = Job.new(
      :operation => 'restore', 
      :backup_node_id => schedule.backup_node_id,
      :host_id => host.id,
      :schedule_id => schedule.id,
      :start_at => Time.now,
      :data => {'restore_data' => restore.data, 'restore_id' => restore.id, 'backup_dir' => host.formatted_host_config_by_name('backup_dir')['backup_dir']}
    )
    @job.assign
    
    
    if @job.save! && restore.update_attributes!(:job_id => @job.id)
      flash[:notice] = "Sucessfully created restore job!"
      redirect_to host_restores_path(host)
    else
      flash[:error] = "Could not create restore job!"
      redirect_to host_restore_schedule_file_index_path(params[:host_id], params[:restore_id], params[:schedule_id], params[:id], :dir => current_dir)
    end
  end
  
end
