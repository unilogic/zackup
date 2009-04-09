module Zfs
  # args = {"flags" => "fn", "pool" => "test_pool", "properties" => { "prop1" => "value1" },"vdev" => "/dev/test"}
  # 
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
      return 1
    end
    
    if args["vdev"]
      arglist << " #{args["vdev"]}"
    else
      return 1
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
  
  def zfs_create
    
  end
  
  def zfs_destroy
    
  end
  def zfs_snapshot
    
  end
  
  def zfs_rollback
    
  end
  
  def zfs_clone
    
  end
  
  def zfs_promote
    
  end
  
  def zfs_rename
    
  end
  
  def zfs_list
    
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
  
end