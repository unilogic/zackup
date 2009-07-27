require 'setup_job'
require 'backup_job'

class RunJob
  
  # Testing if our IP address matches what we can resolve the hostname to.
  # If hostname and IP address are set in the object, resolve the hostname and
  # see if we can find an IP address that matches. If IP address is not matched
  # we'll fill it in with the first IP address we resolve.
  def self.check_hostname(hostname, ip_address=nil)
    begin
      addrinfo = Socket.getaddrinfo(hostname, 22)
    rescue SocketError
      return false
    end
    addrinfo.each do |addr|
      if ip_address && ip_address == addr[3]
        return addr[3]
      elsif ip_address
        next
      else
        return addr[3]
      end
    end
    return false
  end
  
  def self.run(jobs)
    jobs.each do |job|
      if job.aasm_events_for_current_state.include? :finish
        
        unless job.aasm_current_state == :running
          job.run
          job.save!
        end
        
        if job.data['hostname'][:value] && job.data['ip_address'][:value]
          unless self.check_hostname(job.data['hostname'][:value], job.data['ip_address'][:value])
            DaemonKit.logger.warn "Hostname #{job.data['hostname'][:value]} does not match IP address given. Tested by resolving hostname. SKIPPING!"
            next
          end
        end
        
        if job.operation == 'setup'
          setupJob = SetupJob.new(:ip_address => job.data['ip_address'][:value],
            :hostname => job.data['hostname'][:value],
            :size => job.data['quota'][:value]
          )
          
          rstatus = setupJob.create_zfs_fs!
          path = setupJob.path
          if rstatus[0] == 0 && path[0] == 0
            job.finish
            job.data['backup_dir'] = { :value => path[1] }
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
            :host_type => job.data['host_type'][:value],
            :local_backup_dir => job.data['backup_dir'][:value]
          )
          rstatus = backupJob.run(job.data)
          
          
        elsif job.operation == 'restore'
          nil
        end
      end # End if
    end # End each
    
  end # End run method
  
end # End Class