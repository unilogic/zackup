class HostsController < ApplicationController
  before_filter :require_user
  
  def index
    @hosts = Host.all
  end
  
  def new
    @host = Host.new
    
    config_item_group_and_defaults
  end
  
  def get_sub_form
    @config_items = ConfigItem.find_all_by_parent_id(params[:id])
    @js_after = true
    respond_to do |format|
      format.js { render :partial => 'get_sub_form' }
    end
  end
  
  def get_sub_form_host_form
    @config_items = ConfigItem.find_all_by_parent_id(params[:id])
    @js_replace = true
    respond_to do |format|
      format.js { render :partial => 'get_sub_form_host_form' }
    end
  end
  
  def create
    @host = Host.new(params[:host])
    validated_params = validate_params(params[:config_item])
    if validated_params && @host.save
      validated_params.each {|k,v|
        if k && v
          if k == 'no_submit'
            next
          else
            HostConfig.create(:host => @host, :config_item_id => k, :value => v) 
          end
        end   
      }
      HostConfig.create(:host => @host, :config_item => ConfigItem.find_by_name('status'), :value => 'new')
      flash[:notice] = "Host created!"
      redirect_to hosts_path
    else
      config_item_group_and_defaults
      render :action => :new
    end
  end
  
  def show
    @host = Host.find(params[:id])
  end

  def edit
    @host = Host.find(params[:id])
    @config_groups = ConfigItem.find(:all, :conditions => ["parent_id IS ? AND name NOT IN (?)", nil, 'defaults'])
    @host_configs = @host.find_host_configs_configurable
    @host_type = @host.find_host_config_by_name('host_type')
    if @host_type
      @host_type_children = ConfigItem.find_all_by_parent_id @host_type.config_item_id
      @host_type_current = ConfigItem.find @host_type.value.to_i
    end
  end
  
  def update
    @host = Host.find(params[:id])
    @host_configs = HostConfig.find_all_by_host_id(@host.id)
    new_configs = []
    failed = false
    
    if params[:config_item]
      validated_params = validate_params(params[:config_item])
      if validated_params && @host.update_attributes(params[:host])
        validated_params.each {|k,v|
          unless found = HostConfig.find_by_host_id_and_config_item_id(@host.id, k)
            HostConfig.create(:host => @host, :config_item_id => k, :value => v)
            new_configs.push(k.to_i)
          else
            found.update_attributes!(:value => v)
            new_configs.push(k.to_i)
          end
        }
      else
        failed = true
      end
    end
    if params[:host_config]
      host_config = {}
      validated_params = validate_params(params[:host_config])
      validated_params.each {|k,v|
        if k == 'no_submit'
          next
        else
          host_config[k] = { 'value' => v }
          new_configs.push(k.to_i)
        end
      } if validated_params
      HostConfig.update(host_config.keys, host_config.values) || failed = true
    end
    
    @host_configs.each { |config|
      if config.name == 'status'
        next
      end
      unless new_configs.include? config.id
        config.destroy || failed = true
      end
    }
    #puts new_configs
    unless failed
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
      flash[:notice] = "Host deleted!"
    end
    respond_to do |format|
      format.html { redirect_to hosts_path }
      format.xml  { head :ok }
    end
  end
  
  def disable
    @host = Host.find(params[:id])
    
    if @host.disable
      flash[:notice] = "Host disabled!"
      redirect_to hosts_path
    else
      render :action => :index
    end
  end
  
  def enable
    @host = Host.find(params[:id])
    
    if @host.enable
      flash[:notice] = "Host enabled!"
      redirect_to hosts_path
    else
      render :action => :index
    end
  end
  
  private 
  
  # Create all the variables used in new and create
  def config_item_group_and_defaults
    @host_type_item = ConfigItem.find_by_name('host_type')
    if @host_type_item
      @host_type_children = ConfigItem.find_all_by_parent_id @host_type_item.id
    end
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
    
  end
  
  def validate_params(params_hash)
    params_hash.each { |k,v|
      
      #Hack to filter and modify password params, so passwords are filtered in logs
      modifiable = String.new(k)
      if modifiable.gsub!(/^(\d+)_password$/,'\1')
        params_hash[modifiable] = v
      end
      
      # Check confirmation against original
      if params_hash["#{modifiable}_confirmation"]
        if params_hash["#{modifiable}_confirmation"] != v
          config_item = ConfigItem.find modifiable
          flash[:error] = "#{config_item.name} and Confirmation Do Not Match!"
          return false
        else
          params_hash.delete("#{modifiable}_confirmation")
        end
      end
    }
    return params_hash
  end
end
