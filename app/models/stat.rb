class Stat < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :node
  
end
