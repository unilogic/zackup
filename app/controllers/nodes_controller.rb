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
    
  end
end
