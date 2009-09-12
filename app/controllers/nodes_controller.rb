class NodesController < ApplicationController
  before_filter :require_user
  
  def index
    @nodes = Node.all
  end
  
  def new
    @node = Node.new
  end
  
  def create
    @node = Node.new(params[:node])

    if @node.save
      flash[:notice] = "Node created!"
      redirect_to nodes_path
    else
      render :action => :new
    end
  end
  
  def show
    
    @node = Node.find(params[:id])
    
    # Grab all node stats for this node for the past day.
    stats = Stat.find_all_by_node_id @node, :conditions => ["created_at > ?", 1.days.ago.localtime]
 		
    @cpu = Chartr::LineChart.new(
      :xaxis => {:mode => 'time', :labelsAngle => 45},
      :HtmlText => false,
      :lines => {:show => true, :fill => true}
    )
    
    cpu_data = []
    disk_data_used = []
    disk_data_avail = []
    
    #Build data arrays.
    stats.each do |stat|
      if stat.created_at && stat.cpu_load_avg
        cpu_avgs = YAML::load(stat.cpu_load_avg)
        # Need milliseconds
        created_at_in_ms = (stat.created_at.to_f * 1000).to_i
        cpu_data << [created_at_in_ms, cpu_avgs[0]]
        if stat.disk_used
          disk_data_used << [created_at_in_ms, stat.disk_used]
        end
        if stat.disk_avail
          disk_data_avail << [created_at_in_ms, stat.disk_avail]
        end
      end
    end
    
    @cpu.data = [{'data' => cpu_data, 'label' => 'CPU Load Avg'}]
    
    
    @disk = Chartr::LineChart.new(
      :xaxis => {:mode => 'time', :labelsAngle => 45},
      :HtmlText => false,
      :lines => {:show => true, :fill => true}
    )
    
    @disk.data = [
      {'data' => disk_data_used, 'label' => 'Disk Space Used (Bytes)'}, 
      {'data' => disk_data_avail, 'label' => 'Disk Space Avail (Bytes)'}]
    
    
  end
  
  def edit
    @node = Node.find(params[:id])
  end
  
  def update
    @node = Node.find(params[:id])
    if @node.update_attributes(params[:node])
      flash[:notice] = "Node updated!"
      redirect_to nodes_path
    else
      render :action => :edit
    end
  end
  
  def destroy
    @node = Node.find(params[:id])
    if request.delete?
      flash[:notice] = "Node deleted!"
      @node.destroy
    end
    respond_to do |format|
      format.html { redirect_to nodes_path }
      format.xml  { head :ok }
    end
  end
end
