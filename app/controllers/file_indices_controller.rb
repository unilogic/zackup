class FileIndicesController < ApplicationController
  
  def index
    @file_indices = FileIndex.find_all_by_host_id_and_schedule_id(params[:host_id], params[:schedule_id])
  end
  
  def show
    @file_index = FileIndex.find(params[:id])
    @parent = params[:dir]
    @dir = Jqueryfiletree.new(@parent).get_content
    
  end
end
