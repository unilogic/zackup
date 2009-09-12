class NodesController < ApplicationController
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
    
    node = Node.find(params[:id])
    
    stats = Stat.find_all_by_node_id node, :conditions => ["created_at > ?", 10.minutes.ago.localtime]
 		
    @cpu = Chartr::LineChart.new(
      :xaxis => {:mode => 'time', :labelsAngle => 45},
      :HtmlText => false,
      :points => {:show => true},
      :mouse => {:track => true},
      :lines => {:show => true, :fill => true}
    )
    
    cpu_data = []
    disk_data = []
    stats.each do |stat|
      if stat.created_at && stat.cpu_load_avg
        cpu_avgs = YAML::load(stat.cpu_load_avg)
        # Need milliseconds
        cpu_data << [(stat.created_at.to_f * 1000).to_i, cpu_avgs[0]]
      end
    end
    @cpu.data = [{'data' => cpu_data, 'label' => 'CPU Load Avg'}]
    
    
    @disk = Chartr::LineChart.new(
      :xaxis => {:mode => 'time', :labelsAngle => 45},
      :HtmlText => false,
      :points => {:show => true},
      :mouse => {:track => true},
      :lines => {:show => true, :fill => true}
    )
    
    
    
    
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
