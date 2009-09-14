require 'chronic'

module Scheduler
  
  def parseSchedules(options)
    schedules = Schedule.find_all_by_status 'enabled'
    schedules.each do |schedule|
      if schedule.host.status == 'enabled'
        parseSchedule(schedule,options)
      end
    end
  end
  
  def parseSchedule(schedule,options)
    if schedule.status == 'enabled'
      
      time_now = Time.now
      date_today = Date.today
      
      start_datetime = Time.parse("#{schedule.start_date} #{schedule.start_time}")
      # As long as start time is now or in the past process the schedule
      if start_datetime - time_now <= 0
        schedule_alt = schedule
        schedule = parseExistingJobs(schedule)
        
        if schedule == 1
          Rails.logger.warn "Zackup::Scheduler - #{schedule_alt.name} for host #{schedule_alt.host.name} has too many errored jobs found, SKIPPING!"
          return 1
        elsif schedule == 2
          Rails.logger.info "Zackup::Scheduler - #{schedule_alt.name} for host #{schedule_alt.host.name} has an existing job still running, waiting, paused, new, or assigned, SKIPPING!"
          return 2
        elsif schedule == 3
          Rails.logger.error "Zackup::Scheduler - ERROR: Found a new backup Dir for schedule: #{schedule_alt.name} on #{schedule_alt.host.name}, SKIPPING!"
          return 3
        end
        schedule_alt = nil
        
        # Parse out retention policy for this schedule.
        rstatus = parseRetentionPolicy(schedule,options)
        if rstatus == 1
          Rails.logger.error "Zackup::Scheduler - No retention policy found for schedule: #{schedule.name} for host #{schedule.host.name}. SKIPPING!"
          return 1
        elsif rstatus == 2
          Rails.logger.warn "Zackup::Scheduler - Retention policy found for schedule: #{schedule.name} for host #{schedule.host.name} could not be saved!"
        end  
        
        
        if backup_dirs = schedule.host.find_host_config_by_name('backup_dir')
          begin
            backup_dirs = YAML::load(backup_dirs.value)
          rescue TypeError
            backup_dirs = backup_dirs.value
          end
          unless backup_dirs && backup_dirs[schedule.id]
            Rails.logger.warn "Could not find a backup_dir for host #{schedule.host.name}, schedule id #{schedule.id}, SKIPPING!"
            return 3
          end
        end
        
        job = Job.new
        job.schedule_id = schedule.id
        job.host_id = schedule.host_id
        job.operation = 'backup'
        
        if schedule.backup_node_id
          job.backup_node_id = schedule.backup_node_id
          job.assign
        end
        
        if schedule.repeat == 'hourly'
          if Setting.default.new_job_based_start == 'finish'
            if schedule.last_finish
              job.start_at = schedule.last_finish + (schedule.every.to_i * 3600)
            else
              job.start_at = time_now
            end
          elsif Setting.default.new_job_based_start == 'start'
            if schedule.last_start
              job.start_at = schedule.last_start + (schedule.every.to_i * 3600)
            else
              job.start_at = time_now
            end
          end
        elsif schedule.repeat == 'daily'
          if Setting.default.new_job_based_start == 'finish'
            if schedule.last_finish
              job.start_at = schedule.last_finish + (schedule.every.to_i * 86400)
            else
              job.start_at = time_now
            end
          elsif Setting.default.new_job_based_start == 'start'
            if schedule.last_start
              job.start_at = schedule.last_start + (schedule.every.to_i * 86400)
            else
              job.start_at = time_now
            end
          end
        elsif schedule.repeat == 'weekly'
          # Note: We don't care if new_job_based_start is start or finish we use start time here. It doesn't make sense otherwise.
          
          if schedule.on
            # De-YAML our selected days array
            days = YAML::load(schedule.on)
          else
            # TODO: Better handling of this error
            return 3
          end
  
          if days.include? Date::DAYNAMES[date_today.wday]
            # From now on we know a backup is supposed to be run today
            
            # Week day number of last day of week selected in this schedule 
            last_dayOfWeek_index = Date::DAYNAMES.index(days.last)
            
            if schedule.last_start

              # The number of days from today to the last day selected in schedule, plus the number of days since the last backup.
              # This calculation allows for easy checking to see if we need to skip weeks.
              days_plus_correction = (last_dayOfWeek_index - date_today.wday) + ((time_now - schedule.last_start) / 86400).to_i
              
              if days_plus_correction <= 7
                
                # Still in the same week as the last start, so just start the job based on start_time
                job.start_at = Time.parse(schedule.start_time)
                
              elsif (schedule.every.to_i * 7) <= days_plus_correction
                
                # At this point we should know we have skipped the appropriate number of weeks.
                job.start_at = Time.parse(schedule.start_time)
              end                
            else
              
              # Job has never been run before
              job.start_at = time_now
            end
          end

        elsif schedule.repeat == 'monthly'
          
          # Note: We don't care if new_job_based_start is start or finish we use start time here.
          # It doesn't make sense to pay attention to finish time in a monthly context.
          if schedule.last_start
            
            # If last start is is at least "every" months back from today
            if (schedule.last_start.to_date >>(schedule.every.to_i)) - date_today <= 0
              
              #Using start_time instead of last_start time. 
              job.start_at = Time.parse(schedule.start_time)
            end
          else
            job.start_at = time_now
          end
        
        end
        
        # Don't add the job yet if we are more than one parse interval away from starting time
        # This is to reduce clutter in the jobs window. Also don't add if start_at is nil as that means nothing was found for
        # this schedule to be run.
        # Note: parse_interval is in minutes
        if ! job.start_at.nil? && job.start_at - time_now <= (options['parse_interval'].to_i || 120)
          if host = schedule.host
            job.data = host.host_configs_to_yaml
          end
          if job.save!
            schedule.update_attributes!( :last_start => Time.now )
          end
        end
      end
    end
  end
  
  def parseExistingJobs(schedule)
    jobs = schedule.jobs
    finished_time = DateTime.new
    error_count = 0
    running_jobs = 0

    jobs.each do |job|
      # See if there are updates to the schedule's last_finished_at time
      if job.aasm_current_state == :finished && job.finished_at
        if schedule.last_finish && job.finished_at > schedule.last_finish
          finished_time = job.finished_at
        elsif schedule.last_finish.nil?
          finished_time = job.finished_at
        end
        
        # Check for finished jobs that have a backup_dir value in the data field.
        if job.data['backup_dir'][:value]
          host = schedule.host
          job_backup_dirs = ""
          begin
            job_backup_dirs = YAML::load(job.data['backup_dir'][:value])
          rescue TypeError
            job_backup_dirs = job.data['backup_dir'][:value]
          end
          # No reason to bother processing anymore if we don't have a backup_dir for our current schedule.
          if backup_dir = job_backup_dirs[schedule.id]
            if host_config = host.find_host_config_by_name('backup_dir')
            
              # For safety if for some reason we find a job for a schedule that already has a backup_dir set
              # we'll skip it for now.
              # TODO: figure out how better to handle this condition
              host_config_value = ""
              begin
                host_config_value = YAML::load(host_config.value)
              rescue TypeError
                host_config_value = host_config.value
              end

              if host_config_value[schedule.id] && host_config_value[schedule.id] != backup_dir
                Rails.logger.error "Zackup::Scheduler - Old: #{host_config_value[schedule.id]} New: #{backup_dir}"
                return 3
              elsif host_config_value[schedule.id].nil?
                host_config_value[schedule.id] = job_backup_dirs[schedule.id]
                host_config.value = host_config_value
                host_config.save!
              end
            
            else
              config_item = ConfigItem.find_by_name('backup_dir')
              HostConfig.create(:host_id => schedule.host.id, :config_item_id => config_item.id, :value => {schedule.id => backup_dir})
            end
          end
        end
      # Count how many errored jobs the schedule has
      elsif job.aasm_current_state == :errored
        error_count += 1
      elsif job.aasm_current_state != :canceled && job.aasm_current_state != :finished
        running_jobs += 1
      end
    end
    
    # Check to make sure finished_time actually was touched, then save the schedule back to the db
    unless finished_time == DateTime.new
      schedule.update_attributes!(:last_finish => finished_time)
    end
    
    # If we are over the max error count, return 1
    if error_count >= Setting.default.max_error_retries
      return 1
    end
    
    # If there are other running jobs and we're not forcing, return 2
    if running_jobs > 0 && Setting.default.force_backup_runs == false
      return 2
    end
    
    return schedule
  end
  
  def parseRetentionPolicy(schedule,options)
    
    unless retention_policy = schedule.retention_policy
      return 1
    end
    unless file_indices = FileIndex.find_all_by_host_id_and_schedule_id(schedule.host_id, schedule.id, :select => "id, snapname", :order => 'created_at DESC')
      return 0
    end
    
    unless host = schedule.host
      return 0
    end
    
    host.formatted_host_config_by_name('backup_dir')
    
    min_time = Chronic.parse("#{retention_policy.keep_min_time} #{retention_policy.min_time_type} before now")
    
    max_time = Chronic.parse("#{retention_policy.keep_max_time} #{retention_policy.max_time_type} before now")
    
    min_versions = retention_policy.keep_min_versions
    
    max_versions = retention_policy.keep_max_versions
    
    keep_snaps = []
    
    drop_snaps = []
    
    # Take latest min_versions worth of elements from file_indices
    if min_versions
      keep_snaps << file_indices[0..min_versions - 1]
    end
    
    # Take the oldest max_versions worth of elements from file_indices
    if max_versions
      unless max_versions >= file_indices.length
        drop_snaps << file_indices[max_versions..-1]
      end
    end
    
    if min_time || max_time
      file_indices.each do |file_index|
        if file_index.snapname && time_parsed = Time.parse(file_index.snapname)
          if min_time
            if time_parsed >= min_time
              keep_snaps << file_index
            end
          end
          if max_time
            if time_parsed < max_time
              drop_snaps << file_index
            end
          end
        end
      end
    end
    
    keep_snaps.uniq!
    drop_snaps.uniq!
    keep_snaps.flatten!
    drop_snaps.flatten!
    
    job = Job.new(
      :backup_node_id => schedule.backup_node_id,
      :host_id => schedule.host_id,
      :schedule_id => schedule.id,
      :start_at => Time.now,
      :operation => 'maintenance'
    )
    
    #If we have both keep and drop snaps we remove any of keep_snaps' elements from drop_snaps
    if keep_snaps.length > 0 && drop_snaps.length > 0
      drop_snaps -= keep_snaps
    # If we just have keep_snaps we remove any of keep_snaps' elements from the original file_indices
    # and then use whats left over. In otherwords we just keep whats specified to save, and delete everything else.
    elsif keep_snaps.length > 0
      drop_snaps = file_indices - keep_snaps
    end
    
    # Lastly if drop_snaps is specified and keep_snaps is not. We simply use drop_snaps as is. 
    # This is commented out as this logic already applies. However its left here for to show what happens when drop_snap
    # is used alone.
    #elsif drop_snaps.length > 0
    #  job.data = {'drop_snaps' => drop_snaps}
    #end
      
    unless drop_snaps.empty?
      job.data = {
        'drop_snaps' => drop_snaps,
        'backup_dir' => host.formatted_host_config_by_name('backup_dir')['backup_dir']
      }
      job.assign
      unless job.save!
        return 2
      end
    end
    
  end # End parseRetentionPolicy
  
  # Cleanup old jobs.
  def cleanJobs
    if Setting.default.keep_jobs.days
      cleaned_jobs = Job.destroy_all(["start_at <= :c AND (status = 'finished' OR status = 'errored' OR status = 'canceled')", {:c => Setting.default.keep_jobs.days.ago.localtime}])
      if cleaned_jobs
        Rails.logger.info "Zackup::Scheduler - #{cleaned_jobs.count} Jobs Finished, Errored, and Canceled Jobs Pruned"
      end
    end
  end # End cleanJobs
  
  # Cleanup old stats.
  def cleanStats
    if Setting.default.keep_stats
      cleaned_stats = Stat.destroy_all(["created_at <= ?", Setting.default.keep_stats.days.ago.localtime])
      if cleaned_stats
        Rails.logger.info "Zackup::Scheduler - #{cleaned_stats.count} Stats Pruned"
      end
    end
  end # End cleanStats
end # End Module