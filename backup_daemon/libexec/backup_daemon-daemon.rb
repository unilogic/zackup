require 'job'
require 'node'
require 'run_job'

require 'zlib'
require 'archive/tar/minitar'

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

if @settings['time_zone']
  Time.zone = @settings['time_zone']
else
  DaemonKit.logger.warn "Time Zone not set in settings.yml, using UTC!"
  Time.zone = "UTC"
end

# Startup Work and Checks 
ActiveRecord::Base.connection_pool.with_connection do |conn|
  DaemonKit.logger.info "Startup Checks Running"
  @node = Node.find_by_ip_address @settings['ip_address']
  @node ||= Node.find_by_hostname @settings['hostname']

  unless @node
    DaemonKit.logger.error "Node matching IP Address or Hostname not found in Database, EXITING!"
    exit 1
  else
    unless @node.backup_node
      DaemonKit.logger.error "Found Node Does Not Have Backup Service Enabled, EXITING!"
      exit 1
    end
    DaemonKit.logger.info "I am node id: #{@node.id}"
    @node.last_seen = Time.now_zone
    unless @node.save!
      DaemonKit.logger.error "Cannot Successfully Update Last Seen Time in Database, EXITING!"
      exit 1
    end
  end
end

# Test that rsync is available.
test_rsync = %x[rsync --version 2>&1]
unless $?.exitstatus == 0
  DaemonKit.logger.error "Rsync executable could not be run, EXITING! Ensure it's installed, Error: #{test_rsync}"
  exit 1
end

# Make sure that the temp keys dir exists. If not create it.
unless File.directory? "#{DAEMON_ROOT}/tmp/keys"
  FileUtils::mkdir_p "#{DAEMON_ROOT}/tmp/keys", :mode => 0700
end

#unless @settings['backup_root'] && File.directory?(@settings['backup_root'])
#  DaemonKit.logger.error "Cannot File Directory Specified as backup_root in settings.yml, EXITING!"
#  exit
#end

# Main loop
loop do
  
  ActiveRecord::Base.connection_pool.with_connection do |conn|
    DaemonKit.logger.info "I'm running"
    # Update Last Seen
    @node = Node.find @node.id
    @node.last_seen = Time.now_zone
    unless @node.save!
      DaemonKit.logger.error "Cannot Successfully Update Last Seen Time in Database, EXITING!"
      exit 1
    end
    if myJobs = @node.backup_jobs
      RunJob.get_node_stats(@node)
      RunJob.run(myJobs)
    end  
  end
  sleep @settings['loop_interval'] || 60
end
