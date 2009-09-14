include Scheduler

class ParseSchedulesTask < Rooster::Task
  
  define_schedule do |s|
    
    config_file = YAML.load_file(File.dirname(__FILE__) + '/../../../config/scheduler.yml')
    options = config_file[ENV["RAILS_ENV"]]
    schedule_parse_interval = options['parse_interval'] || 120
    
    s.every schedule_parse_interval, :tags => [self.name] do 
      begin
        
        log "#{self.name} starting at #{Time.now.to_s(:db)}"
        
        parseSchedules(options)
        cleanJobs
        cleanStats
      ensure
        log "#{self.name} completed at #{Time.now.to_s(:db)}"
        
        # We release the db connection as we sleep.
        ActiveRecord::Base.connection_pool.release_connection
      end
    end
  end

end