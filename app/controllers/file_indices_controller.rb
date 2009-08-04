class FileIndicesController < ApplicationController
  
  def index
    @host_id = params[:host_id]
    @schedule_id = params[:schedule_id]
    @restore_id = params[:restore_id]
    @file_indices = FileIndex.find_all_by_host_id_and_schedule_id(params[:host_id], params[:schedule_id], :select => "id,snapname")
  end
  
  def get_file_index
    redirect_to host_restore_schedule_file_index_path(params[:host_id], params[:restore_id], params[:schedule_id], params[:file_index][:id])
  end
  
  def show
    @host_id = params[:host_id]
    @schedule_id = params[:schedule_id]

    @file_index = FileIndex.find(params[:id])
    @file_indices = FileIndex.find_all_by_host_id_and_schedule_id(params[:host_id], params[:schedule_id], :select => "id,snapname")
    @restore = Restore.find(params[:restore_id])
    
    @current_dir = params[:dir] || ""
    @current_dir.gsub!(/^\/*/, "/")
    
    @dirs_files = @file_index.get_content(@current_dir)
  end
  
  def add

    current_dir = params[:dir]
    add_item = params[:item]
    
    @file_index = FileIndex.find(params[:id], :select => "id,snapname")
    @restore = Restore.find(params[:restore_id])
    
    if @restore.data
      @restore.data << {@file_index.snapname => "#{current_dir}/#{add_item}"}
    else
      @restore.data = [{@file_index.snapname => "#{current_dir}/#{add_item}"}]
    end
    
    if @restore.save!
      flash[:notice] = "#{add_item} added to restore!"
      redirect_to host_restore_schedule_file_index_path(params[:host_id], params[:restore_id], params[:schedule_id], params[:id], :dir => current_dir)
    else
      flash[:error] = "Could not add #{add_item} to restore!"
      redirect_to host_restore_schedule_file_index_path(params[:host_id], params[:restore_id], params[:schedule_id], params[:id], :dir => current_dir)
    end
    
  end
end
