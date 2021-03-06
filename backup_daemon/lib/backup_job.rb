require 'zackup_crypt'
require 'rbsync'
require 'zackup_crypt'
require 'tempfile'

require 'zfs'
include Zfs

class BackupJob
  FIELDS = %w{ hostname ip_address host_type directories exclusions local_backup_dir port }.map! { |s| s.to_sym }.freeze
  attr_accessor *FIELDS
  @@settings = DaemonKit::Config.load('settings').to_h
  
  DEFAULTS = { :hostname => nil, :ip_address => nil , :host_type => nil, :directories => nil, :exclusions => nil, :post => 22 }.freeze
  
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

    if self.host_type == 'ssh'
      
      key = ""
      key_pass = ""
      begin
        # Open the key and unencrypt it if needed.
        # Note if the key is stored unencrypted already, this line will not complain, 
        # and simply verify its a valid RSA key.
        begin
          key_pass = ZackupCrypt.the_key.decrypt64(args['ssh_private_key_password'][:value])
        
        # Theres a chance the password isn't encrypted so we'll use the original string.
        rescue OpenSSL::Cipher::CipherError
          key_pass = args['ssh_private_key_password'][:value]
        end
        
        key = OpenSSL::PKey::RSA.new(args['ssh_private_key'][:value], key_pass)
      rescue OpenSSL::Cipher::CipherError
        message = "Could not decrypt the private key password for #{self.hostname}"
        DaemonKit.logger.warn message
        return 1, message
      rescue OpenSSL::PKey::RSAError
        message = "Could not open private SSH key for #{self.hostname}, it is either invalid or encrypted and we don't have the correct password"
        DaemonKit.logger.warn message
        return 1, message
      end
      rstatus = do_ssh_backup(args['ssh_login'][:value], key)
      return rstatus
    end
  end
  
  def do_snapshot(mountpoint=self.local_backup_dir)
    # args = {"flags" => "r", "display_properties" => "", "sort_asc" => "", "sort_desc" => "", "type" => "", "target" => ""}
    list = zfs_list("target" => mountpoint)
    if list[0] == 0
      filesystem = list[1].first['name']
      snapname = Time.now_zone.to_s.gsub!(/\s/, "_")
      
      #args = {"flags" => "r", "filesystem" => "/pool/folder", volume => "pool", "snapname" => "name"}
      rstatus = zfs_snapshot("filesystem" => filesystem, "snapname" => Time.now_zone.to_s.gsub!(/\s/, "_"))
      if rstatus[0] == 0
        return 0,snapname
      else
        return rstatus
      end
    else
      return list
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
    
    unless self.local_backup_dir
      raise ArgumentError, "Local Backup dir must be specified!"
    end
    
    begin     
      tempfile = Tempfile.new(basename, "#{DAEMON_ROOT}/tmp/keys")
      tempfile.write(key)
      tempfile.close
      
      # Adding this so SSH will never prompt for anything. Security be damned!
      option_args = "-o stricthostkeychecking=no -o userknownhostsfile=/dev/null -o batchmode=yes -o passwordauthentication=no "
      
      #remote remote_paths local_path argv
      ssh_args = "ssh -l #{ssh_login} -p #{self.port} -i #{tempfile.path} #{option_args}"
      
      exclude_args = ""
      if self.exclusions && exclude_array = self.exclusions.split("\n")
        exclude_array.each do |exclude|
          exclude_args << "--exclude=#{exclude} "
        end
      end
      
      # Archive and relative paths args
      argv = "-a -R #{exclude_args} -e \"#{ssh_args}\" "
      rbsync = Rbsync.new(:remote => self.hostname, 
        :remote_paths => self.directories, 
        :local_path => self.local_backup_dir, 
        :argv => argv )
    
    # Ensure we close the tempfile that has the ssh key in it.
    ensure
      #tempfile.close!
    end
    return rbsync
  end

end