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
    @restore_id = params[:restore_id]
    
    @file_index = FileIndex.find(params[:id])
    @file_indices = FileIndex.find_all_by_host_id_and_schedule_id(params[:host_id], params[:schedule_id], :select => "id,snapname")
    
    @current_dir = params[:dir] || ""
    @current_dir.gsub!(/^\/*/, "/")
    
    @dirs_files = @file_index.get_content(@current_dir)
  end
  
  def add
    host_id = params[:host_id]
    schedule_id = params[:schedule_id]
    
    file_index_id = params[:file_index_id]
    current_dir = params[:dir]
    add_item = params[:item]
    
    
  end
end
