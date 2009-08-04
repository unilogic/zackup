class Restore < ActiveRecord::Base
  belongs_to :user
  belongs_to :host
end
