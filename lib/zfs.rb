module Zfs
  
  
  #
  # Input: args = {"flags" => "fn", "pool" => "test_pool", "properties" => { "prop1" => "value1" },"vdev" => "/dev/test"}
  # Returns: [Exit status, Command Output]
  def zpool_create(args)
    arglist = ""
    if args["flags"]
      arglist << " -#{args["flags"]}"
    end
    
    if args["mountpoint"]
      arglist << " -m #{args["mountpoint"]}"
    end
    
    if args["properties"]
      args["properties"].each { |key,value| 
        arglist << " -o #{key}=#{value}"
      }
    end
    
    if args["pool"]
      arglist << " #{args["pool"]}"
    else
      return 1, "Pool must be defined"
    end
    
    if args["vdev"]
      arglist << " #{args["vdev"]}"
    else
      return 1, "Vdev must be defined"
    end
    result = %x[zpool create#{arglist} 2>&1]
    
    return $?.exitstatus,result
  end
  
  def zpool_destroy
    
  end
  
  def zpool_add
    
  end
  
  def zpool_remove
    
  end
  
  def zpool_list
    
  end
  
  def zpool_iostat
    
  end
  
  def zpool_online
    
  end
  
  def zpool_offline
    
  end
  
  def zpool_clear
    
  end
  
  def zpool_attach
    
  end
  
  def zpool_detach
    
  end
  
  def zpool_replace
    
  end
  
  def zpool_scrub
    
  end
  
  def zpool_import
    
  end
  
  def zpool_export
    
  end
  
  def zpool_upgrade
    
  end
  
  def zpool_history
    
  end
  
  def zpool_get
    
  end
  
  def zpool_set
    
  end
  
  # args = {"flags" => "ps", "blocksize" => "512", "properties" => { "prop1" => "value1" },"filesystem" => "/home/test"}
  # args = {"flags" => "ps", "blocksize" => "512", "properties" => { "prop1" => "value1" },"size" => "1024", "volume" => "pool/newpool"}
  # Returns: [Exit status, Command Output]
  #
  def zfs_create(args)
    arglist = ""
    if args["flags"]
      arglist << " -#{args["flags"]}"
    end
    
    properties = ""
    if args["properties"]
      args["properties"].each { |key,value| 
        properties << " -o #{key}=#{value}"
      }
    end
    
    if args["filesystem"] && ( args["size"] || args["volume"] )
      return 1, "Filesystem and size or volume cannot be defined at the same time"
    elsif args["filesystem"] && !( args["size"] || args["volume"] )
      arglist << properties
      arglist << " #{args["filesystem"]}"
    elsif args["size"] && args["volume"]
      if args["blocksize"]
        arglist << " -b #{args["blocksize"]}"
      end
      arglist << properties
      arglist << " -V #{args["size"]}"
      arglist << " #{args["volume"]}"
    else
      return 1, "Filesystem or size and volume must be defined"
    end

    result = %x[zfs create#{arglist} 2>&1]
    
    return $?.exitstatus,result
  end
  
  # args = {"flags" => "rRf", "filesystem" => "/pool/folder", volume => "pool", "snapshot" => "snapName"}
  def zfs_destroy(args)
    arglist = ""
    if args["flags"]
      arglist << "-#{args["flags"]}"
    end
    
    if args["filesystem"]
      arglist << " #{args["filesystem"]}"
    elsif args["snapshot"]
      arglist << " #{args["snapshot"]}"
    elsif args["volume"]
      arglist << " #{args["volume"]}"
    else
      return 1, "Filesystem, snapshot or volume must be defined"
    end
    result = %x[zfs destroy#{arglist} 2>&1]
    
    return $?.exitstatus,result
  end
  
  #args = {"flags" => "r", "filesystem" => "/pool/folder", volume => "pool", "snapname" => "name"}
  def zfs_snapshot(args)
    arglist = ""
    if args["flags"]
      arglist << "-#{args["flags"]}"
    end
    if ! args["snapname"]
      return 1, "Snapname must be defined"
    elsif args["filesystem"] && args["volume"]
      return 1, "Filesystem and volume cannot be defined at the same time"
    elsif args["filesystem"]
      arglist << " #{args["filesystem"]}@#{args["snapname"]}"
    elsif args["volume"]
      arglist << " #{args["volume"]}@#{args["snapname"]}"
    else
      return 1, "Snapname and volume or filesystem must be defined"
    end
    result = %x[zfs snapshot#{arglist} 2>&1]
    
    return $?.exitstatus,result
  end
  
  # args = {"flags" => "rRf", "snapshot"}
  def zfs_rollback(args)
    arglist = ""
    if args["flags"]
      arglist << "-#{args["flags"]}"
    end

    if args["snapshot"]
      arglist << " #{args["snapshot"]}"
    else
      return 1, "Snapshot must be defined"
    end
    result = %x[zfs rollback#{arglist} 2>&1]
    
    return $?.exitstatus,result
  end
  
  def zfs_clone(args)
    arglist = ""
    if args["flags"]
      arglist << "-#{args["flags"]}"
    end
    if args["snapshot"]
      arglist << " #{args["snapshot"]}"
    elsif args["filesystem"] && args["volume"]
      return 1, "Filesystem and volume cannot be defined at the same time"
    elsif args["filesystem"]
      arglist << " #{args["filesystem"]}"
    elsif args["volume"]
      arglist << " #{args["volume"]}"
    else
      return 1, "Snapshot and volume or filesystem must be defined"
    end
    result = %x[zfs clone#{arglist} 2>&1]
    
    return $?.exitstatus,result
  end
  
  # args = {"clone-filesystem" => "file/system"}
  def zfs_promote(args)
    arglist = ""
    if args["clone-filesystem"]
      arglist << " #{args["clone-filesystem"]}"
    else
      return 1, "Clone-filesystem must be defined"
    end
    result = %x[zfs promote#{arglist} 2>&1]
    
    return $?.exitstatus,result
  end
  
  def zfs_rename
    
  end
    
  def zfs_list(args)
    result = parse_tab_output(%x[zfs list -H 2>&1])
    return $?.exitstatus,result
  end
  
  def zfs_set
    
  end
  
  def zfs_get
    
  end
  
  def zfs_inherit
    
  end
  
  def zfs_upgrade
    
  end
  
  def zfs_mount
    
  end
  
  def zfs_unmount
    
  end
  
  def zfs_share
    
  end
  
  def zfs_unshare
    
  end
  
  def zfs_send
    
  end
  
  def zfs_receive
    
  end
  
  def zfs_allow
    
  end
  
  def zfs_unallow
    
  end
  
  protected
  
  def parse_tab_output(str)
    lines = str.split("\n")
    cols = lines[0].chomp.downcase!.split("\t")
    lines.shift
    record = []
    lines.each do |line|
      vals = line.chomp.split("\t")
      record.push((0...cols.size).map {|j|
                    { cols[j] => vals[j] }
            }
      )
    end
    return record
  end
  
end