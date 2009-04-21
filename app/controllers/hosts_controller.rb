class HostsController < ApplicationController
  before_filter :require_user
  
  def index
    @hosts = Host.all
  end
  
  def new
    @host = Host.new
    @config_items = ConfigItem.all
  end
  
  def create
    @host = Host.new(params[:host])
    
    if @host.save
      flash[:notice] = "Host created!"
      redirect_to hosts_path
    else
      render :action => :new
    end
  end
  
  def show
    @host = Host.find(params[:id])
  end

  def edit
    @config_items = ConfigItem.all
    @host = Host.find(params[:id])
    @host_configs = @host.host_configs
  end
  
  def update
    @host = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Host updated!"
      redirect_to hosts_path
    else
      render :action => :edit
    end
  end
  
  def destroy
    @host = Host.find(params[:id])
    if request.delete?
      @host.destroy
    end
    respond_to do |format|
      format.html { redirect_to hosts_path }
      format.xml  { head :ok }
    end
  end
  
  def disable
    @host = Host.find(params[:id])
    
    if @host.disable
      flash[:notice] = "Host disabled"
      redirect_to hosts_path
    else
      render :action => :index
    end
  end
  
  def enable
    @host = Host.find(params[:id])
    
    if @host.enable
      flash[:notice] = "Host enabled"
      redirect_to hosts_path
    else
      render :action => :index
    end
  end
end
