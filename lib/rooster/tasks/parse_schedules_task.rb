include Scheduler

class ParseSchedulesTask < Rooster::Task
  # Fail-safe Default
  schedule_parse_interval = "5m"

  define_schedule do |s|
    begin
      # The Schedule_parse_interval setting is in minutes
      schedule_parse_interval = "#{Setting.default.schedule_parse_interval}m"
    ensure
      ActiveRecord::Base.connection_pool.release_connection
    end
    
    s.every schedule_parse_interval, :tags => [self.name] do 
      begin
        
        log "#{self.name} starting at #{Time.now.to_s(:db)}"
        
        parseSchedules
        
      ensure
        log "#{self.name} completed at #{Time.now.to_s(:db)}"
        ActiveRecord::Base.connection_pool.release_connection
      end
    end
  end
end