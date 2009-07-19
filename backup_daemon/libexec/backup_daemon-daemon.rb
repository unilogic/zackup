require 'job'
require 'node'

# Change this file to be a wrapper around your daemon code.

# Do your post daemonization configuration here
# At minimum you need just the first line (without the block), or a lot
# of strange things might start happening...
DaemonKit::Application.running! do |config|
  # Trap signals with blocks or procs
  # config.trap( 'INT' ) do
  #   # do something clever
  # end
  # config.trap( 'TERM', Proc.new { puts 'Going down' } )
  
  config.trap( 'HUP' ) do
    @settings = DaemonKit::Config.load('settings').to_h
  end
end

#Load settings.yml
@settings = DaemonKit::Config.load('settings').to_h

# Startup Work and Checks 
ActiveRecord::Base.connection_pool.with_connection do |conn|
  DaemonKit.logger.info "Startup Checks Running"
  @node = Node.find_by_ip_address @settings['ip_address']
  @node ||= Node.find_by_hostname @settings['hostname']

  unless @node
    DaemonKit.logger.error "Node matching IP Address or Hostname not found in Database, EXITING!"
    exit
  else
    unless @node.backup_node
      DaemonKit.logger.error "Found Node Does Not Have Backup Service Enabled, EXITING!"
      exit
    end
    DaemonKit.logger.info "I am node id: #{@node.id}"
    @node.last_seen = Time.now
    unless @node.save!
      DaemonKit.logger.error "Cannot Successfully Update Last Seen Time in Database, EXITING!"
      exit
    end
  end
end


# Main loop
loop do
  
  ActiveRecord::Base.connection_pool.with_connection do |conn|
    DaemonKit.logger.info "I'm running"
    # Update Last Seen
    @node.last_seen = Time.now
    unless @node.save!
      DaemonKit.logger.error "Cannot Successfully Update Last Seen Time in Database, EXITING!"
      exit
    end
    if myJobs = @node.backup_jobs
      myJobs.each do |job|
        
      end
    end  
  end
  sleep @settings['loop_interval'] || 60
end
