require 'zackup_crypt'
require 'rbsync'
require 'zackup_crypt'
require 'tempfile'

require 'zfs'
include Zfs

class BackupJob
  FIELDS = %w{ hostname ip_address host_type directories exclusions local_backup_dir }.map! { |s| s.to_sym }.freeze
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
    
    # Ensure the local back dir actually exists.
    if self.local_backup_dir
      unless File.directory? self.local_backup_dir
        raise ArgumentError, "Local backup directory not found."
      end
    end
  end
  
  # Ensure the local back dir actually exists.
  def local_backup_dir=(local_backup_dir)
    unless File.directory? local_backup_dir
       raise ArgumentError, "Local backup directory not found."
     end
  end
  
  def run(args)

    if self.host_type == 'sftp'
      
      key = ""
      
      begin
        # Open the key and unencrypt it if needed.
        # Note if the key is stored unencrypted already, this line will not complain, 
        # and simply verify its a valid RSA key.
        key_pass = ZackupCrypt.the_key.decrypt64(args['sftp_private_key_password'][:value])
        key = OpenSSL::PKey::RSA.new(args['sftp_private_key'][:value], key_pass)
      rescue OpenSSL::Cipher::CipherError
        message = "Could not decrypt the private key password for #{self.hostname}"
        DaemonKit.logger.warn message
        return 1, message
      rescue OpenSSL::PKey::RSAError
        message = "Could not open private SSH key for #{self.hostname}, it is either invalid or encrypted and we don't have the correct password"
        DaemonKit.logger.warn message
        return 1, message
      end
      do_sftp_backup(args['sftp_login'][:value], key)
    end
  end
  
  private 
  
  def do_ssh_backup(ssh_login, key)
    # Pick a very random filename. Default privs on tempfile is 600. Still not secure though.
    o = [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
    basename = (0..50).map{ o[rand(o.length)]  }.join
    
    unless self.hostname
      raise ArgumentError, "Hostname must be specified!"
    end
    
    unless self.directories
      raise ArgumentError, "Directories must be specified!"
    end
    
    unless self.ip_address
      raise ArgumentError, "IP Address must be specified!"
    end
    
    begin     
      tempfile = Tempfile.new(basename, "#{DAEMON_ROOT}/tmp/keys")
      tempfile.write(key)
      #remote remote_paths local_path argv
      ssh_args = "ssh -l #{ssh_login} -i #{tempfile.path}"
      exclude_args = ""
      if self.exclusions && exclude_array = self.exclusions.split("\n")
        exclude_array.each do |exclude|
          exclude_args << "--exclude=#{exclude} "
        end
      end
      argv = "-av #{exclude_args} -e \"#{ssh_args}\" "
      rbsync = Rbsync.new(:remote => self.hostname, :remote_paths => self.directories, :argv => argv )
    
    # Ensure we close the tempfile that has the ssh key in it.
    ensure
      tempfile.close!
    end 
  end
  
  def do_snapshot(filesystem)
    
  end
end