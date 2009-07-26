require 'zackup_crypt'
require 'rbsync'

class BackupJob
  FIELDS = %w{ hostname ip_address host_type directories exclusions }.map! { |s| s.to_sym }.freeze
  attr_accessor *FIELDS
  @@settings = DaemonKit::Config.load('settings').to_h
  
  DEFAULTS = { :hostname => nil, :ip_address => nil , :host_type => nil, :directories => nil, :exclusions => nil }.freeze
  
  def initialize(args = {})
    args = args ? args.merge(DEFAULTS).merge(args) : DEFAULTS
    
    FIELDS.each do |attr|
      args.each_pair do | key, value |
          instance_variable_set("@#{attr}", args[attr])
      end
    end
    
  end
  
  def run(args)
    do_sftp_backup('asdf', 'asdf1')
    if self.host_type == 'sftp'
      do_sftp_backup(args['sftp_login'][:value], args['sftp_password'][:value])
    end
  end
  
  def do_sftp_backup(sftp_login, sftp_password)
    puts sftp_login
    puts self.exclusions
  end
  
  def do_snapshot
  
  end
end