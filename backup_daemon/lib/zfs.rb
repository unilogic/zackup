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
  
#  def zpool_destroy
#    
#  end
#  
#  def zpool_add
#    
#  end
#  
#  def zpool_remove
#    
#  end
#  
#  def zpool_list
#    
#  end
#  
#  def zpool_iostat
#    
#  end
#  
#  def zpool_online
#    
#  end
#  
#  def zpool_offline
#    
#  end
#  
#  def zpool_clear
#    
#  end
#  
#  def zpool_attach
#    
#  end
#  
#  def zpool_detach
#    
#  end
#  
#  def zpool_replace
#    
#  end
#  
#  def zpool_scrub
#    
#  end
#  
#  def zpool_import
#    
#  end
#  
#  def zpool_export
#    
#  end
#  
#  def zpool_upgrade
#    
#  end
#  
#  def zpool_history
#    
#  end
#  
#  def zpool_get
#    
#  end
#  
#  def zpool_set
#    
#  end
  
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
  
  # args = {"flags" => "rp", "source" => "pool", "target" => "newPool"}
  def zfs_rename(args)
    arglist = ""
    if args["flags"]
      arglist << "-#{args["flags"]}"
    end
    
    if args["source"] && args["target"]
      arglist << " #{args["source"]} #{args["target"]}"
    else
      return 1, "Source and Target must be defined"
    end
    result = %x[zfs rename#{arglist} 2>&1]
    
    return $?.exitstatus,result
  end
  
  # args = {"flags" => "r", "display_properties" => "", "sort_asc" => "", "sort_desc" => "", "type" => "", "target" => ""}
  def zfs_list(args = {})
    arglist = ""
    if args["flags"]
      # Ignore the H flag as its mucks with parse_output
      arglist << " -#{args["flags"].delete('H')}"
    end
    
    if args["display_properties"]
      arglist << " -o #{args["display_properties"]}"
    end
    
    if args["sort_asc"]
      arglist << " -s #{args["sort_asc"]}"
    end
    
    if args["sort_desc"]
      arglist << " -S #{args["sort_desc"]}"
    end
    
    if args["type"]
      arglist << " -t #{args["type"]}"
    end
    
    if args["target"]
      arglist << " #{args["target"]}"
    end
    result = %x[zfs list#{arglist} 2>&1]
    if $?.exitstatus == 0
      result = parse_output(result)
    end
    return $?.exitstatus,result
  end
  
  #  args = {"properties" => { "prop1" => "value1" }, "filesystem" => "pool/tank", "volume" => "pool"}}
  def zfs_set(args)
    arglist = ""
    if args["properties"]
      args["properties"].each { |key,value| 
        arglist << " #{key}=#{value}"
        break
      }
    else
      return 1, "Property must be defined"
    end
    
    if args["filesystem"] && args["volume"]
      return 1, "Filesystem and volume cannot be defined at the same time"
    elsif args["filesystem"]
      arglist << " #{args["filesystem"]}"
    elsif args["volume"]
      arglist << " #{args["volume"]}"
    else
      return 1, "Filesystem or volume must be defined"
    end
    
    result = %x[zfs set#{arglist} 2>&1]
    
    return $?.exitstatus,result 
  end
  
  # args = {"flags" => "rHp", "field" => "field1,field2", "source" => "source1,source2", "property" => "nfsshare,iscsishare", 
  # "target" => "filesystem|volume|snapshot"}
  def zfs_get(args)
    arglist = ""
    cols = ['name', 'property', 'value', 'source']
    arglist << " -H"
    if args["flags"]
      arglist << args["flags"].delete('H')
    end
    
    if args["field"]
      cols = args["field"].split(',')
      arglist << " -o #{args["field"]}"
    end
    
    if args["source"]
      arglist << " -s #{args["source"]}"
    end
    
    if args["properties"]
      arglist << " #{args["properties"]}"
    else
      arglist << " all"
    end
    
    if args["target"]
      arglist << " #{args["target"]}"
    else
      return 1, "Target must be defined with a filesystem, volume, or snapshot"
    end
    
    result = %x[zfs get#{arglist} 2>&1]
    if $?.exitstatus == 0
      result = parse_tabular_output(result, cols)
    end
    return $?.exitstatus,result
  end
  
  def zfs_inherit(args)
    arglist = ""
    if args["flags"]
      arglist << args["flags"]
    end
    
    if args["property"] && args["target"]
      arglist << " #{args["property"]} #{args["target"]}"
    else
      return 1, "Property and Target must be defined"
    end
    
    result = %x[zfs inherit#{arglist} 2>&1]
    
    return $?.exitstatus,result 
  end
  
  def zfs_upgrade(args)
    arglist = ""
    if args["flags"]
      # Currently this module does not support the -v flag on zfs upgrade
      arglist << " #{args["flags"].delete('v')}"
    end
    
    if args["version"]
      arglist << " -V #{args["version"]}"
    end
    
    if args["all"] && args["filesystem"]
      return 1, "Cannot define all and filesystem at the same time"
    elsif args["all"]
      arglist << " -a"
    elsif args["filesystem"]
      arglist << " #{args["filesystem"]}"
    else
      return 1, "All or filesystem must be defined"
    end

    result = %x[zfs upgrade#{arglist} 2>&1]
    
    return $?.exitstatus,result
  end
  
  def zfs_mount(args = {})
    
    if args.length > 0
      arglist = ""
      if args["flags"]
        arglist << " -#{args["flags"]}"
      end
  
      if args["opts"]
        arglist << " -o #{args["opts"]}"
      end
  
      if args["filesystem"]
        arglist << " #{args["filesystem"]}"
      elsif args["all"]
        arglist << " -a"
      else
        return 1, "Filesystem or all must be defined"
      end
      result = %x[zfs mount#{arglist} 2>&1]
    else
      result = %x[zfs mount 2>&1]
      if $?.exitstatus == 0
        result = parse_output(result, ['filesystem','mountpoint'])
      end
    end
    
    return $?.exitstatus,result
  end
  
  def zfs_unmount(args)
    arglist = ""
    if args["flags"]
      arglist << " -#{args["flags"]}"
    end
    if args["filesystem"]
      arglist << " #{args["filesystem"]}"
    elsif args["mountpoint"]
      arglist << " #{args["mountpoint"]}"
    elsif args["all"]
      arglist << " -a"
    else
      return 1, "Filesystem, mountpoint or all must be defined"
    end
    result = %x[zfs unmount#{arglist} 2>&1]
    
    return $?.exitstatus,result
  end
  
  def zfs_share(args)
    arglist = ""
    
    if args["all"]
      arglist << " -a"
    elsif args["filesystem"]
      arglist << " #{args["filesystem"]}"
    else
      return 1, "All or filesystem must be defined"
    end
    
    result = %x[zfs share#{arglist} 2>&1]
    
    return $?.exitstatus,result
  end
  
  def zfs_unshare(args)
    arglist = ""
    if args["all"]
      arglist << " -a"
    elsif args["filesystem"]
      arglist << " #{args["filesystem"]}"
    elsif args["mountpoint"]
      arglist << " #{args["mountpoint"]}"
    else
      return 1, "All, filesystem, or mountpoint must be defined"
    end
    
    result = %x[zfs unshare#{arglist} 2>&1]
    
    return $?.exitstatus,result
  end
  
#  def zfs_send(args)
#    arglist = ""
#    if args["flags"]
#      arglist << " -#{args["flags"]}"
#    end
#    
#    if args["inter_snapshot"] && args["incre_snapshot"]
#      return 1, "Inter_snapshot and incre_snapshot cannot be defined at the same time"
#    elsif args["inter_snapshot"]
#      arglist << " -I #{args["inter_snapshot"]}"
#    elsif args["incre_snapshot"]
#      arglist << " -i #{args["incre_snapshot"]}"
#    end
#    
#    if args["snapshot"]
#      arglist << " args["snapshot"]"
#    else
#      return 1, "Snapshot must be defined"
#    end
#    
#    # This needs to be plumbed somehow, reading in an entire snapshot into a var will break something.
#    #result = %x[zfs share#{arglist} 2>&1]
#    
#    return $?.exitstatus,result
#  end
  
#  def zfs_receive
#    
#  end
#  
#  def zfs_allow
#    
#  end
#  
#  def zfs_unallow
#    
#  end
  
  protected
  
  def parse_output(str, cols = [])
    lines = str.split("\n")
    if cols.size == 0
      cols = lines[0].chomp.squeeze(" ").downcase!.split(" ")
      lines.shift
    end
    
    record = []
    temp = {}
    lines.each do |line|
      vals = line.chomp.squeeze(" ").split(" ")
      (0...cols.size).map {|j|
        temp[cols[j]] = vals[j]
      }
      record << temp
      temp = {}
    end
    return record
  end
  
  def parse_tabular_output(str, cols)
    lines = str.split("\n")
    
    record = []
    temp = {}
    lines.each do |line|
      vals = line.chomp.split("\t")
      (0...cols.size).map {|j|
         temp[cols[j]] = vals[j]
      }
      record << temp
      temp = {}
    end
    return record
  end
end