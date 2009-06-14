class Setting < ActiveRecord::Base
  include ConfigManager
  
  serialize :settings, Hash
  validate_on_update :validate_settings
  
  #Defaults
  setting :registration_enable, :boolean, true
  setting :max_error_retries, :integer, 3
  setting :force_backup_runs, :boolean, false
  setting :new_job_based_start, :string, 'start'
  setting :schedule_parse_interval, :integer, 5
  
  
  
  def initialize
    super
    self.settings = {}
  end
  
  def self.default
    s = Setting.find :first
    if s.nil?
      Setting.new
    else
      s
    end
  end
  
  private

    def validate_settings
      return
    end
end
