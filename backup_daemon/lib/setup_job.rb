require 'zfs'
include Zfs

class SetupJob
  FIELDS = %w{ hostname size ip_address filesystem }.map! { |s| s.to_sym }.freeze
  attr_accessor *FIELDS
  @@settings = DaemonKit::Config.load('settings').to_h
  
  DEFAULTS = { :hostname => nil, :size => nil, :ip_address => nil, :filesystem => nil }.freeze
  
  def initialize(args = {})
    args = args ? args.merge(DEFAULTS).merge(args) : DEFAULTS
    
    FIELDS.each do |attr|
      args.each_pair do | key, value |
          instance_variable_set("@#{attr}", args[attr])
      end
    end
    
  end
    
  def create_zfs_fs!
    unless backup_zvol = @@settings['backup_zvol']
      raise ArgumentError, "backup_root not specified in settings.yml"
    end
    o = [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
    
    # Check that the filesystem does not already exist. We loop 5 times looking for a new filesystem name.
    # Break once we find a non-existant name.
    status = nil
    
    (0..5).each do
      rand = (0..5).map{ o[rand(o.length)]  }.join
      self.filesystem = backup_zvol + '/' + self.ip_address + '_' + rand
      check = zfs_list("target" => self.filesystem)
      if check[0] == 1 && check[1] =~ /dataset does not exist/
        rstatus = zfs_create({"properties" => { "quota" => self.size }, "filesystem" => self.filesystem})
        snapdir_status = set_snapdir
        if snapdir_status[0] == 0
          status = rstatus
          break
        else
          status = snapdir_status
          break
        end
      end
    end
    if status
      return status
    else
      return 1,"After 5 tries no new backup directory found."
    end
  end
  
  def set_snapdir(filesystem=self.filesystem, prop='visible')
    zfs_set("properties" => { "snapdir" => prop }, "filesystem" => filesystem )
  end
  
  def path(filesystem=self.filesystem)
    path = zfs_get("field" => 'value', "properties" => 'mountpoint', "target" => filesystem )
    
    if path[0] == 0
      return 0, path[1].first['value']
    else
      return path
    end
  end
end