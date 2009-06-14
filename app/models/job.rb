class Job < ActiveRecord::Base
  include AASM
  
  belongs_to :host
  belongs_to :scheduler_node, :class_name => "Node"
  belongs_to :backup_node, :class_name => "Node"
  belongs_to :schedule
  
  validates_inclusion_of :operation, :in => %w( backup restore )
  
  serialize :data, Hash
  
  aasm_column :status
  aasm_initial_state :new

  aasm_state :new
  aasm_state :assigned
  aasm_state :finished
  aasm_state :running
  aasm_state :waiting
  aasm_state :paused
  aasm_state :canceled
  aasm_state :errored

  aasm_event :assign do
   transitions :to => :assigned, :from => [:new]
  end

  aasm_event :finish do
   transitions :to => :finished, :from => [:running, :assigned]
  end

  aasm_event :run do
   transitions :to => :running, :from => [:assigned, :new]
  end

  aasm_event :wait do
    transitions :to => :waiting, :from => [:new, :running, :assigned]
  end

  aasm_event :pause do
    transitions :to => :paused, :from => [:new, :running, :assigned, :waiting]
  end

  aasm_event :unpause do
    transitions :to => :waiting, :from => [:paused]
  end
  
  aasm_event :cancel do
    transitions :to => :canceled, :from => [:new, :running, :assigned, :paused, :waiting]
  end

  aasm_event :error do
   transitions :to => :errored, :from => [:new, :running, :assigned, :waiting, :paused]
  end
end
