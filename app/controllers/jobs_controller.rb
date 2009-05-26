class JobsController < ApplicationController
  def index
    @jobs = Job.all
  end
  
  def new
    
  end
  
  def create
    
  end
  
  def update_status
    @job = Job.find(params[:id])
    if job.aasm_events_for_current_state.include? params[:job][:status].intern
      @job.aasm_write_state(params[:job][:status].intern)
    else
      redirect_to job_path(@job)
    end
  end
  
  def destroy
    
  end
  
end
