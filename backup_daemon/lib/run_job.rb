require 'setup_job'
require 'backp_job'

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
            DaemonKit.logger.info "Successfully setup host #{job.data['ip_address'][:value]}"
          else
            job.error
            job.data = {'exit_code' => rstatus[0], 'message' => rstatus[1]}
            job.save!
            DaemonKit.logger.warn "Error while trying to setup host, #{rstatus[1]}"
          end
        
        elsif job.operation == 'maintenance'
          nil
        elsif job.operation == 'backup'
          backupJob = BackupJob.new(:ip_address => job.data['ip_address'][:value],
            :hostname => job.data['hostname'][:value],
            :host_type => job.data['host_type'][:value]
             )
          rstatus = backupJob.run(job.data)
          
          
        elsif job.operation == 'restore'
          nil
        end
      end
    end
  end
end