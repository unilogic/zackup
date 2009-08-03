class FileIndicesController < ApplicationController
  
  def index
    @file_indices = FileIndex.find_all_by_host_id_and_schedule_id(params[:host_id], params[:schedule_id])
  end
  
  def show
    @host_id = params[:host_id]
    @schedule_id = params[:schedule_id]
    # Don't find data here. As it has the potential to be a huge var.
    @file_index = FileIndex.find(params[:id], :select => "id,snapname")
  end
  
  def content
    @file_index = FileIndex.find(params[:id])
    @current_dir = params[:dir] || ""
    @dirs_files = @file_index.get_content(@current_dir) 
  end
end
