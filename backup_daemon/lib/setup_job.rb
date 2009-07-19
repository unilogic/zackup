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
    unless backup_root = @@settings['backup_root']
      raise ArgumentError, "backup_root not specified in settings.yml"
    end
    
    filesystem = backup_root + '/' + self.ip_address
    
    zfs_create({"properties" => { "quota" => self.size }, "filesystem" => filesystem})
  end
end