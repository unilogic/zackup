class JobsController < ApplicationController
  before_filter :require_user
  
  def index
    @jobs = Job.paginate(:all, :page => params[:page], :order => "id DESC")
  end
  
  def show
    @job = Job.find(params[:id])
    if @job.data["error"]
      @error_message = @job.data["error"]["message"]
      @error_exit_code = @job.data["error"]["exit_code"]
    end
  end
  def update_status
    job = Job.find(params[:id])
    if job.aasm_current_state == :paused && params[:status] == 'pause'
      job.unpause
      params[:status] = 'waiting'
    elsif job.aasm_events_for_current_state.include? params[:status].intern
      eval("job.#{params[:status]}")
    else
      flash[:error] = "Job status could not be updated!"
      redirect_to jobs_path
      return
    end
    
    if job.save!
      flash[:notice] = "Job #{job.aasm_current_state}!"
    else
      flash[:error] = "Job status could not be updated!"
    end
    
    redirect_to jobs_path
  end
  
end
