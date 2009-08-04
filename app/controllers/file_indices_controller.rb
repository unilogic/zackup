class FileIndicesController < ApplicationController
  
  def index
    @host_id = params[:host_id]
    @schedule_id = params[:schedule_id]
    @file_indices = FileIndex.find_all_by_host_id_and_schedule_id(params[:host_id], params[:schedule_id], :select => "id,snapname")
  end
  
  def get_file_index
    
    redirect_to :show
  end
  
  def show
    @host_id = params[:host_id]
    @schedule_id = params[:schedule_id]
    
    @file_index = FileIndex.find(params[:id])
    @current_dir = params[:dir] || ""
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
