class Job < ActiveRecord::Base
  include AASM
  
  aasm_column :status
  aasm_initial_state :new

  aasm_state :new
  aasm_state :running
  aasm_state :finished
  aasm_state :assigned
  aasm_state :errored
  
  aasm_event :assign do
   transitions :to => :assigned, :from => [:new]
  end

  aasm_event :finish do
   transitions :to => :finished, :from => [:running]
  end
  
  aasm_event :run do
   transitions :to => :running, :from => [:assigned]
  end
  
  aasm_event :error do
   transitions :to => :errored, :from => [:new, :running, :assigned, :done]
  end
end
