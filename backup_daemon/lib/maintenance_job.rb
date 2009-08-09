require 'zfs'
include Zfs

class MaintainceJob
  def self.destroy_snaps(drop_snaps, backup_dir)
    list = zfs_list("target" => backup_dir)
    if list[0] == 0
      filesystem = list[1].first['name']
      
      drop_snaps.each do |drop_snap|
        # args = {"flags" => "rRf", "filesystem" => "/pool/folder", volume => "pool", "snapshot" => "snapName"}
        rstatus = zfs_destroy("snapshot" => "#{filesystem}@#{drop_snap.snapname}")
       
        unless rstatus[0] == 0 && drop_snap.destroy
          return rstatus
        end
      end
    else
      return list
    end
  end
end