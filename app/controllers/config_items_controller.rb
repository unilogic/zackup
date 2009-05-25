class ConfigItemsController < ApplicationController
  before_filter :require_user

  def index
    @config_items = ConfigItem.all
  end

  def new
    @config_item = ConfigItem.new
    @config_groups = ConfigItem.all
  end

  def create
    @config_item = ConfigItem.new(params[:config_item])

    if @config_item.save
      flash[:notice] = "Config item created!"
      redirect_to config_items_path
    else
      render :action => :new
    end
  end

  def show
    @config_item = ConfigItem.find(params[:id])
  end

  def edit
    @config_item = ConfigItem.find(params[:id])
    @config_groups = ConfigItem.all
    @config_groups.delete(@config_item)
  end

  def update
    @config_item = ConfigItem.find(params[:id])
    if @config_item.update_attributes(params[:config_item])
      flash[:notice] = "Config item updated!"
      redirect_to config_items_path
    else
      render :action => :edit
    end
  end

  def destroy
    @config_item = ConfigItem.find(params[:id])
    if request.delete?
      @config_item.destroy
    end
    respond_to do |format|
      format.html { redirect_to config_items_path }
      format.xml  { head :ok }
    end
  end
end
