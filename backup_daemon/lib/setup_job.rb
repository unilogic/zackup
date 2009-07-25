require 'zfs'
include Zfs

class SetupJob
  FIELDS = %w{ hostname size ip_address }.map! { |s| s.to_sym }.freeze
  attr_accessor *FIELDS
  @@settings = DaemonKit::Config.load('settings').to_h
  
  DEFAULTS = { :hostname => nil, :size => nil, :ip_address => nil }.freeze
  
  
  
  def initialize(args = {})
    args = args ? args.merge(DEFAULTS).merge(args) : DEFAULTS
    
    FIELDS.each do |attr|
      args.each_pair do | key, value |
          instance_variable_set("@#{attr}", args[attr])
      end
    end
    
  end
  
  def hostname
    @hostname
  end
  
  def hostname=(hostname)
    @hostname = hostname
  end
  
  def size
    @size
  end
  
  def size=(size)
    @size = size
  end
  
  def ip_address
    @ip_address
  end
  
  def ip_address=(ip_address)
    @ip_address = ip_address
  end
    
  def create_zfs_fs!
    unless backup_zvol = @@settings['backup_zvol']
      raise ArgumentError, "backup_root not specified in settings.yml"
    end
    
    filesystem = backup_zvol + '/' + self.ip_address
    
    # Check that the filesystem does not already exist.
    check = zfs_list("target" => filesystem)
    if check[0] == 1 && check[1] =~ /dataset does not exist/
      return zfs_create({"properties" => { "quota" => self.size }, "filesystem" => filesystem})
    else
      # Technically this is an error condition so let RunJob know that.
      check[0] = 1
      check[1] = "#{filesystem} already exists"
      return check
  end
end