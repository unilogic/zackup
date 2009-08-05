class Restore < ActiveRecord::Base
  belongs_to :user
  belongs_to :host
  belongs_to :schedule
  belongs_to :job, :dependent => :destroy
  
  serialize :data, Array

end
