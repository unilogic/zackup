class RetentionPoliciesController < ApplicationController
  def edit
    @schedule = Schedule.find(params[:schedule_id])
    @host = Host.find(params[:host_id])
    unless @retention_policy = @schedule.retention_policy
      @retention_policy = RetentionPolicy.new(:schedule_id => @schedule.id)
    end
  end
  
end
