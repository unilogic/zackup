# Original Source taken from http://github.com/kevincolyar/rbsync

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
    
  end
 
  def remote(paths)
    remote = self.remote
    paths.split("\n").each do |path|
      path.chomp!
      remote << ":#{path} "
    end
  end
 
  def get_paths(argv)
    path = {}
    path[:remote] = argv.shift
 
    if argv[0] and /^\-/ =~ argv[0]
      path[:local] = File.expand_path('.')
    else
      path[:local] = File.expand_path(argv.shift || '.') 
    end
 
    path[:local] += '/' if File.directory? path[:local]
    path[:remote] = map_path(path[:remote] + ':' +  path[:local])
    return path
  end
 
  def get_rsync_args(argv)
    rsync_args = @rsync_args + ' '
    rsync_args += argv.join ' '
    return rsync_args
  end
 
  def push_to(argv)
    path = get_paths(argv)
    rsync_args = get_rsync_args(argv)
 
    DaemonKit.logger.info "Pushing #{path[:local]} to #{path[:remote]} with options #{rsync_args}"
    exec("rsync \"#{path[:local]}\" \"#{path[:remote]}\" #{rsync_args}")
  end
 
  def pull_from(argv)
    path = get_paths(argv)
    rsync_args = get_rsync_args(argv)
 
    DaemonKit.logger.info "Pulling #{path[:remote]} to #{path[:local]} with options #{rsync_args}"
    exec("rsync \"#{path[:remote]}\" \"#{path[:local]}\" #{rsync_args}")
  end
 
end