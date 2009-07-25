require 'setup_job'

class RunJob
  def self.run(jobs)
    jobs.each do |job|
      if job.aasm_events_for_current_state.include? :finish
        
        unless job.aasm_current_state == :running
          job.run
          job.save!
        end
        
        if job.operation == 'setup'
          setupJob = SetupJob.new(:ip_address => job.data['ip_address'][:value],
            :hostname => job.data['hostname'][:value],
            :size => job.data['quota'][:value]
          )
          
          rstatus = setupJob.create_zfs_fs!
          if rstatus[0] == 0
            job.finish  
            job.save!
          else
            job.error
            job.data = rstatus[1]
            job.save!
            DaemonKit.logger.error "Error while trying to setup host, #{rstatus[1]}"
          end
        
        elsif job.operation == 'maintenance'
    
        elsif job.operation == 'backup'
    
        elsif job.operation == 'restore'
    
        end
      end
    end
  end
end