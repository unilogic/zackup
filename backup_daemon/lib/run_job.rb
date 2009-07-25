require 'setup_job'

class RunJob
  def self.run(jobs)
    jobs.each do |job|
      if job.operation == 'setup'
        setupJob = SetupJob.new(:ip_address => job.data['ip_address'][:value],
          :hostname => job.data['hostname'][:value],
          :size => job.data['quota'][:value]
        )
        rstatus = setupJob.create_zfs_fs!
        unless rstatus[0] == 0
          raise "Error while trying to setup host, #{rstatus[1]}"
        end
        
      elsif job.operation == 'maintenance'
    
      elsif job.operation == 'backup'
    
      elsif job.operation == 'restore'
    
      end
    end
  end
end