# Heavily modified from original Source taken from http://github.com/kevincolyar/rbsync

class Rbsync
  
  FIELDS = %w{ remote remote_paths local_path argv }.map! { |s| s.to_sym }.freeze
  attr_accessor *FIELDS
  
  DEFAULTS = { :remote => nil, :remote_paths => nil, :local_path => nil, :argv => nil }.freeze
  
  def initialize(args = {})
    args = args ? args.merge(DEFAULTS).merge(args) : DEFAULTS
    
    FIELDS.each do |attr|
      args.each_pair do | key, value |
          instance_variable_set("@#{attr}", args[attr])
      end
    end
    
    test_rsync = %x[rsync --version 2>&1]
    unless $?.exitstatus == 0
      raise "Rbsync: Rsync executable could not be run ensure it's installed, Error: #{test_rsync}"
    end
  end
  
  def parse_remote_paths(paths)
    full_remote = ""
    if remote = self.remote
      
      paths.split("\n").each do |path|
        path.chomp!
        remote << ":#{path} "
      end
    end
    
    return full_remote
  end
  
  def pull
    unless self.remote
      return 1, "Rbsync: Remote must be specified!"
    end
    
    unless full_remote = parse_remote_paths(self.remote_paths)
      return 1, "Rbsync: Remote paths must be specified!"
    end
    
    unless local = self.local_path
      return 1, "Rbsync: Local path much be specified!"
    end
    
    rsync_args = self.argv
    
    unless File.directory? local
      DaemonKit.logger.warn "Rbsync: Local directory #{local} does not exist!"
      return 1, "Rbsync: Local directory #{local} does not exist!"
    else
    
      DaemonKit.logger.info "Rbsync: Pulling #{self.remote_paths} to #{self.local_path}"
      result = %x[rsync #{rsync_args} \"#{full_remote}\" \"#{local}\" 2>&1]
      return $?.exitstatus,result
    end
  end
 
end