module Scheduler
  def parseSchedules
    schedules = Schedule.all
    schedules.each do |schedule|
      puts parseSchedule(schedule)
    end
  end
  
  def parseSchedule(schedule)
    if schedule.status == 'enabled'
      # As long as start time is now or in the past process the schedule
      start_datetime = Time.parse("#{schedule.start_date} #{schedule.start_time}")
      if start_datetime - Time.now <= 0
        schedule = parseExistingJobs(schedule)
        
        if schedule == 1
          Rails.logger.error "Scheduler - ERROR, Too many errored jobs found"
          return 1
        elsif schedule == 2
          Rails.logger.error "Scheduler - ERROR, Existing job still running, waiting, paused, new, or assigned"
          return 2
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
              job.start_at = Time.now
            end
          elsif Setting.default.new_job_based_start == 'start'
            if schedule.last_start
              job.start_at = schedule.last_start + (schedule.every.to_i * 3600)
            else
              job.start_at = Time.now
            end
          end
        elsif schedule.repeat == 'daily'
          if Setting.default.new_job_based_start == 'finish'
            if schedule.last_finish
              job.start_at = schedule.last_finish + (schedule.every.to_i * 86400)
            else
              job.start_at = Time.now
            end
          elsif Setting.default.new_job_based_start == 'start'
            if schedule.last_start
              job.start_at = schedule.last_start + (schedule.every.to_i * 86400)
            else
              job.start_at = Time.now
            end
          end
        elsif schedule.repeat == 'weekly'
          if Setting.default.new_job_based_start == 'finish'
            if schedule.last_finish
              job.start_at = schedule.last_finish + (schedule.every.to_i * 3600)
            else
              job.start_at = Time.now
            end
          elsif Setting.default.new_job_based_start == 'start'
            if schedule.last_start
              job.start_at = schedule.last_start + (schedule.every.to_i * 3600)
            else
              job.start_at = Time.now
            end
          end
        elsif schedule.repeat == 'monthly'
          if Setting.default.new_job_based_start == 'finish'
            if schedule.last_finish
              job.start_at = schedule.last_finish + (schedule.every.to_i * 3600)
            else
              job.start_at = Time.now
            end
          elsif Setting.default.new_job_based_start == 'start'
            if schedule.last_start
              job.start_at = schedule.last_start + (schedule.every.to_i * 3600)
            else
              job.start_at = Time.now
            end
          end
        end
        
        # Don't add the job yet if we are more than one parse interval away from starting time
        # This is to reduce clutter in the jobs window.
        # Note: schedule_parse_interval is in minutes
        if job.start_at - Time.now <= (Setting.default.schedule_parse_interval * 60)
          if job.save!
            schedule.update_attributes!( :last_start => job.start_at )
          end
        else
          #TODO, Delete this when done testing
          return "Not Yet"
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
        if job.finished_at > finished_time
          finished_time = job.finished_at
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
  
end