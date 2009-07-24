require 'setup_job'

module RunJob
  def run(jobs)
    jobs.each do |job|
      if job.operation == 'setup'
        job.data
        setupJob = SetupJob.new()
      elsif job.operation == 'maintenance'
    
      elsif job.operation == 'backup'
    
      elsif job.operation == 'restore'
    
      end
    end
  end
end