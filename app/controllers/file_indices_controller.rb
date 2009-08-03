class FileIndicesController < ApplicationController
  
  def index
    @file_indices = FileIndex.find_all_by_host_id_and_schedule_id(params[:host_id], params[:schedule_id])
  end
  
  def show
    @file_index = FileIndex.find(params[:id])
    @current_ = params[:dir]
    @dirs_files = @file_index.get_content(@parent)
    
  end
end
