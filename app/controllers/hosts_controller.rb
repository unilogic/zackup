class HostsController < ApplicationController
  before_filter :require_user
  
  def index
    @hosts = Host.all
  end
  
  def new
    @host = Host.new
  end
  
  def create
    @host = Host.new(params[:host])
    if @host.save
      flash[:notice] = "Host created!"
      redirect_to host_url
    else
      render :action => :new
    end
  end
  
  def show
    @host = Host.find(params[:id])
  end

  def edit
    @host = Host.find(params[:id])
  end
  
  def update
    @host = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Host updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
  
  def disable
    @host = Host.find(params[:id])
    
    if @host.disable
      flash[:notice] = "Host disabled"
      redirect_to host_path
    else
      render :action => :index
    end
  end
  
  def enable
    @host = Host.find(params[:id])
    
    if @host.enable
      flash[:notice] = "Host enabled"
      redirect_to host_path
    else
      render :action => :index
    end
  end
end
