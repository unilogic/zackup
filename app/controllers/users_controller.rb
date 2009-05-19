class UsersController < ApplicationController
  before_filter :require_user, :only => [:show, :edit, :update]
  
  def index
    @users = User.all
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end
  
  def show
    if params[:id]
      @user = User.find(params[:id])
    elsif @current_user
      @user = @current_user
    end
  end

  def edit
    if params[:id]
      @user = User.find(params[:id])
    elsif @current_user
      @user = @current_user
    end
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    if request.delete?
      @user.destroy
      flash[:notice] = "User deleted!"
    end
    respond_to do |format|
      format.html { redirect_to users_path }
      format.xml  { head :ok }
    end
  end
end
