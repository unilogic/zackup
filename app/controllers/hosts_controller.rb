class HostsController < ApplicationController
  before_filter :require_user
  
  def index
    @hosts = Host.all
  end
  
  def new
    @host = Host.new
    @config_items = ConfigItem.find_all_by_configurable true
  end
  
  def create
    @host = Host.new(params[:host])
    
    if @host.save
      params[:config_item].each {|k,v|
        HostConfig.create(:host => @host, :config_item_id => k, :value => v)
      }
      HostConfig.create(:host => @host, :config_item => ConfigItem.find_by_name('status'), :value => 'new')
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
    @host = Host.find(params[:id])
    @host_configs = @host.host_configs
  end
  
  def update
    @host = Host.find(params[:id]) # makes our views "cleaner" and more consistent
    if @host.update_attributes(params[:host])
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
