module Scheduler
  def schedule_init(theScheduler)
    theScheduler.every "#{Setting.default.schedule_parse_interval}m", :tags => 'scheduler' do
      parseSchedules
    end
  end
  
  def reschedule(interval=Setting.default.schedule_parse_interval, theScheduler)

    theScheduler.find_by_tag("scheduler").each do |job|
      job.unschedule
    end
    theScheduler.every "#{interval.to_i}m", :tags => 'scheduler' do
      parseSchedules
    end
  end
  
  def parseSchedules
    Rails.logger.info "Scheduler - NOTICE, Starting to parse schedules at #{Time.now}"
    schedules = Schedule.all
    schedules.each do |schedule|
      parseSchedule(schedule)
    end
  end
  
  def parseSchedule(schedule)
    if schedule.status == 'enabled'
      
      time_now = Time.now
      date_today = Date.today
      
      start_datetime = Time.parse("#{schedule.start_date} #{schedule.start_time}")
      # As long as start time is now or in the past process the schedule
      if start_datetime - time_now <= 0
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
        # Note: schedule_parse_interval is in minutes
        if ! job.start_at.nil? && job.start_at - time_now <= (Setting.default.schedule_parse_interval * 60)
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