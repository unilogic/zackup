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
            job.finished_at = Time.now_zone
            if backup_dirs = job.data['backup_dir'][:value]
              backup_dirs = YAML::load(backup_dirs)
              backup_dirs[job.schedule_id] = path[1]
              job.data['backup_dir'] = { :value => backup_dirs }
            else
              job.data['backup_dir'] = { :value => {job.schedule_id => path[1]} }
            end
            
            job.save!
            DaemonKit.logger.info "Successfully setup host #{job.data['ip_address'][:value]}"
          else
            job.error
            job.data['error'] = {'exit_code' => rstatus[0], 'message' => rstatus[1]}
            job.save!
            DaemonKit.logger.warn "Error while trying to setup host, see job id: #{job.id} for more information."
          end
        
        elsif job.operation == 'maintenance'
          nil
          
        elsif job.operation == 'backup'
          
          # Make sure we have a backup dir for this job's schedule before we go on.
          backup_dirs = YAML::load(job.data['backup_dir'][:value])
          unless backup_dirs && backup_dirs[job.schedule_id]
            DaemonKit.logger.warn "Could not find a backup_dir for host #{job.data['hostname'][:value]}, schedule id #{job.schedule_id}, SKIPPING!"
            next
          end
          
          backupJob = BackupJob.new(:ip_address => job.data['ip_address'][:value],
            :hostname => job.data['hostname'][:value],
            :host_type => job.data['host_type'][:value],
            :local_backup_dir => backup_dirs[job.schedule_id],
            :exclusions => job.data['exclusions'][:value],
            :directories => job.data['backup_directories'][:value]
          )
         
          rbsync = backupJob.run(job.data)
          rstatus = rbsync.pull
          
          snap_status = []
          if rstatus[0] == 0
            snap_status = backupJob.do_snapshot
          end
          
          if rstatus[0] == 0 && snap_status[0] == 0
            job.finish
            job.data['new_snapshot'] = snap_status[1]
            job.finished_at = Time.now_zone
            job.save!
            DaemonKit.logger.info "Successfully ran backup job for #{job.data['ip_address'][:value]}"
          else
            job.error
            exit_code = []
            message = []
            if rstatus[0] != 0
              exit_code << rstatus[0]
              message << rstatus[1]
            end
            if snap_status[0] != 0
              exit_code << snap_status[0]
              message << snap_status[1]
            end
            job.data['error'] = {'exit_code' => exit_code, 'message' => rstatus[1]}
            job.save!
            DaemonKit.logger.warn "Error while trying to run backup job for host, #{job.data['ip_address'][:value]}. See job id: #{job.id} for more information."
          end
          
        elsif job.operation == 'restore'
          nil
        end
      end # End if
    end # End each
    
  end # End run method
  
end # End Class