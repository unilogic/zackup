class Setting < ActiveRecord::Base
  include ConfigManager
  
  serialize :settings, Hash
  validate_on_update :validate_settings
  
  #Defaults
  setting :registration_enable, :boolean, true
  
  def initialize
    super
    self.settings = {}
  end
  
  def self.default
    #debugger
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
