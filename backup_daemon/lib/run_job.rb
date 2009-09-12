require 'setup_job'
require 'backup_job'
require 'restore_job'
require 'maintenance_job'

require 'file_index'
require 'custom_find'
require 'stats'

require 'sys/cpu'
include Sys

require 'zfs'
include Zfs

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
  
  def self.run(jobs, node)
    jobs.each do |job|
      if job.aasm_events_for_current_state.include? :finish
        
        unless job.aasm_current_state == :running
          job.run
          job.save!
        end
        
        # Not sure this should live on. Or what ops it should be run in.
        if job.data['hostname'] && job.data['ip_address'] && job.data['hostname'][:value] && job.data['ip_address'][:value]
          unless self.check_hostname(job.data['hostname'][:value], job.data['ip_address'][:value])
            DaemonKit.logger.warn "Hostname #{job.data['hostname'][:value]} does not match IP address given. Tested by resolving hostname. SKIPPING!"
            next
          end
        end
        
        ##### SETUP ######
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
            if job.data['backup_dir'] && backup_dirs = job.data['backup_dir'][:value]
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
        
        ##### MAINTENANCE ######
        elsif job.operation == 'maintenance'
          drop_snaps = job.data['drop_snaps']
          backup_dirs = YAML::load(job.data['backup_dir'][:value])
          
          rstatus = MaintenanceJob.destroy_snaps(drop_snaps, backup_dirs[job.schedule_id])
          
          if rstatus[0] == 0
            job.finish
            DaemonKit.logger.info "Successfully ran maintenance job id: #{job.id}."
          else
            job.error
            job.data['error'] = {'exit_code' => rstatus[0], 'message' => rstatus[1]}
            DaemonKit.logger.warn "Error while running maintenance job. See job id: #{job.id} for more information."
          end
          
          job.save!
             
        ##### BACKUP ######
        elsif job.operation == 'backup'
          
          # Make sure we have a backup dir for this job's schedule before we go on.
          begin
            backup_dirs = YAML::load(job.data['backup_dir'][:value])
          rescue NoMethodError
            DaemonKit.logger.warn "Could not find a backup_dir for host #{job.data['hostname'][:value]}, schedule id #{job.schedule_id}, SKIPPING!"
            next
          end
          
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
         
          if job.data['ssh_port'] && job.data['ssh_port'][:value]
            backupJob.port = job.data['ssh_port'][:value]
          end
          
          rbsync = backupJob.run(job.data)
          rstatus = rbsync.pull
          
          snap_status = []
          if rstatus[0] == 0
            snap_status = backupJob.do_snapshot
          end
          
          file_index_saved = false
          
          if snap_status[0] == 0
            begin
              compressed_file_index = CustomFind.find(snap_status[1], "#{backup_dirs[job.schedule_id]}/.zfs/snapshot")
            
              file_index = FileIndex.new(:data => compressed_file_index, 
                :basepath => "#{backup_dirs[job.schedule_id]}/.zfs/snapshots",
                :host_id => job.host_id,
                :schedule_id => job.schedule_id,
                :snapname => snap_status[1]
                )
                if file_index.save!
                  file_index_saved = true
                end
              rescue Errno::ENOENT
                
              end
          end
          
          if rstatus[0] == 0 && snap_status[0] == 0 && file_index_saved
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
            unless file_index_saved
              message << "File index did not properly save to the database."
            end
            job.data['error'] = {'exit_code' => exit_code, 'message' => rstatus[1]}
            job.save!
            DaemonKit.logger.warn "Error while trying to run backup job for host, #{job.data['ip_address'][:value]}. See job id: #{job.id} for more information."
          end
        
        ##### RESTORE ###### 
        elsif job.operation == 'restore'
          if job.data['restore_data'] && job.data['backup_dir'] && backup_dirs = job.data['backup_dir'][:value]
            backup_dirs = YAML::load(backup_dirs)
            restoreJob = RestoreJob.new(
              :data => job.data['restore_data'],
              :backup_dir => backup_dirs[job.schedule_id]
            )
            
            rstatus = restoreJob.run
            
            if rstatus[0] == 0
              job.finish
              job.data['download_url'] = rstatus[1]
              job.save!
              DaemonKit.logger.info "Successfully ran restore job for Restore ID: #{job.data['restore_id']}"
            else
              job.error
              job.data['error'] = {'exit_code' => exit_code, 'message' => rstatus[1]}
              job.save!
              DaemonKit.logger.warn "Error while trying to run restore job for Restore ID:  #{job.data['restore_id']}. See job id: #{job.id} for more information."
            end
          end
        end
        
        # Add stats to the db.
        get_schedule_stats(job)
        
      end # End if
      

    end # End each
    get_node_stats(node)
  end # End run method
  
  def self.get_schedule_stats(job)
    begin
      backup_dirs = YAML::load(job.data['backup_dir'][:value])
    rescue NoMethodError, TypeError
      DaemonKit.logger.warn "Could not find a backup_dir for host #{job.data['hostname'][:value]}, while trying to add stats, SKIPPING!"
      return nil
    end
    
     stat = nil

      if backup_dirs && backup_dirs[job.schedule_id]
        list = zfs_list("target" => backup_dirs[job.schedule_id])
        filesystem = ""
        if list[0] == 0
          filesystem = list[1].first['name']
        else
          DaemonKit.logger.warn "Get_stats: Can't convert mountpoint into filesystem name"
          return nil
        end

        schedule_stats = zfs_get("flags" => "p", "target" => filesystem, "field" => "property,value", "properties" => "used,available")

        if schedule_stats[0] == 0
          stat = Stat.new
          stat.schedule_id = job.schedule_id
          schedule_stats[1].each do |schedule_stat|
            if schedule_stat["property"] == 'used'
              stat.disk_used = schedule_stat["value"]
            elsif schedule_stat["property"] == 'available'
              stat.disk_avail = schedule_stat["value"]
            end
          end
          if stat.disk_used && stat.disk_avail
            stat.save!
          else
            DaemonKit.logger.warn "Get_stats: zfs_get return sucessfully, but I couldn't find \"used\" or \"available\" disk space for backup_dir #{backup_dirs[job.schedule_id]}"
          end
        else
          DaemonKit.logger.warn "Get_stats: zfs_get returned with an error, #{schedule_stats[1]}"
        end
      end
  end #End get_schedule_stats 
  
  def self.get_node_stats(node)

    settings = DaemonKit::Config.load('settings').to_h
    stat = Stat.new
    stat.cpu_load_avg = CPU.load_avg
    stat.node_id = node.id
    unless backup_zvol = settings['backup_zvol']
      DaemonKit.logger.warn "backup_root not specified in settings.yml, can't add stats!"
      return nil
    end
    
    # args = {"flags" => "rHp", "field" => "field1,field2", "source" => "source1,source2", "properties" => "nfsshare,iscsishare", 
    # "target" => "filesystem|volume|snapshot"}
    node_stats = zfs_get("flags" => "p", "target" => settings['backup_zvol'], "field" => "property,value", "properties" => "used,available")
    if node_stats[0] == 0
      node_stats[1].each do |node_stat|
        if node_stat["property"] == 'used'
          stat.disk_used = node_stat["value"]
        elsif node_stat["property"] == 'available'
          stat.disk_avail = node_stat["value"]
        end
      end
      if stat.disk_used && stat.disk_avail
        stat.save!
      else
        DaemonKit.logger.warn "Get_stats: zfs_get return sucessfully, but I couldn't find \"used\" or \"available\" disk space for node #{node.id}"
      end
    else
      DaemonKit.logger.warn "Get_stats: zfs_get returned with an error, #{node_stats[1]}"
    end    
  end # End get_node_stats
  
end # End Class