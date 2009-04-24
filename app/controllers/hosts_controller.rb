class HostsController < ApplicationController
  before_filter :require_user
  
  def index
    @hosts = Host.all
  end
  
  def new
    @host = Host.new
    @config_groups = ConfigItem.find_all_by_parent_id nil
    
    @config_groups.each { |item|
      if item.name == 'defaults'
        @default_group = item
        @config_groups.delete(item)
        break
      end
    }
    if @default_group
      @default_items = ConfigItem.find_all_by_parent_id_and_configurable(@default_group.id, true)
    end
    @host_type_item = ConfigItem.find_by_name('host_type')
  end
  
  def get_sub_form
    @config_items = ConfigItem.find_all_by_parent_id(params[:id])
    respond_to do |format|
      format.js { render :partial => 'get_sub_form' }
    end
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
    @config_groups = ConfigItem.find(:all, :conditions => ["parent_id IS ? AND name NOT IN (?)", nil, 'defaults'])
    @host_configs = @host.find_host_configs_not_configurable
    @host_type = @host.find_host_config_by_name('host_type')

  end
  
  def update
    @host = Host.find(params[:id])
    if @host.update_attributes(params[:host])
      if params[:config_item]
        params[:config_item].each {|k,v|
          unless found = HostConfig.find_by_host_id_and_config_item_id(@host.id, k)
            HostConfig.create(:host => @host, :config_item_id => k, :value => v)
          else
            found.update_attributes!(:value => v)
          end
        }
      end
      host_config = {}
      params[:host_config].each {|k,v|
        host_config[k] = { 'value' => v }
      }
      HostConfig.update(host_config.keys, host_config.values)
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
