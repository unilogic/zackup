class User < ActiveRecord::Base
  has_many :restores
  acts_as_authentic
end
