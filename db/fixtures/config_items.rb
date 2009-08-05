# Default Category
ConfigItem.seed do |s|
  s.id = 1
  s.name = 'defaults'
  s.description = 'All config items that are by default added to all hosts'
  s.configurable = false
  s.parent_id = nil
  s.display_type = nil
end

## Default Items ##

# Ip Address
ConfigItem.seed do |s|
  s.id = 2
  s.name = 'ip_address'
  s.description = 'IP Address'
  s.configurable = true
  s.parent_id = 1
  s.display_type = 'text_field'
end

# DNS Hostname
ConfigItem.seed do |s|
  s.id = 3
  s.name = 'hostname'
  s.description = 'DNS Hostname'
  s.configurable = true
  s.parent_id = 1
  s.display_type = 'text_field'
end

# Status Field, not configurable
ConfigItem.seed do |s|
  s.id = 4
  s.name = 'status'
  s.description = 'Status of Host'
  s.configurable = false
  s.parent_id = 1
  s.display_type = nil
end

# Backup Dirs
ConfigItem.seed do |s|
  s.id = 5
  s.name = 'backup_directories'
  s.description = 'Remote Directories to be Backed Up'
  s.configurable = true
  s.parent_id = 1
  s.display_type = 'text_area'
end

# Backup Dirs
ConfigItem.seed do |s|
  s.id = 6
  s.name = 'exclusions'
  s.description = 'Exclusions to be not backed up'
  s.configurable = true
  s.parent_id = 1
  s.display_type = 'text_area'
end

# Quota
ConfigItem.seed do |s|
  s.id = 7
  s.name = 'quota'
  s.description = 'Quota per backup daemon for a host'
  s.configurable = true
  s.parent_id = 1
  s.display_type = 'text_field'
end

ConfigItem.seed do |s|
  s.id = 8
  s.name = 'backup_dir'
  s.description = 'Hash of backup directories, keys are the node_id of each backup daemon.'
  s.configurable = false
  s.parent_id = 1
  s.display_type = nil
end

# Host Type
ConfigItem.seed do |s|
  s.id = 20
  s.name = 'host_type'
  s.description = 'Type of Host, Samba, SSH, etc'
  s.configurable = false
  s.parent_id = 1
  s.display_type = nil
end

## Host Type Groups ##

#Samba
ConfigItem.seed do |s|
  s.id = 21
  s.name = 'samba'
  s.description = 'All Samba Related Configuration Items'
  s.configurable = false
  s.parent_id = 20
  s.display_type = nil
end

ConfigItem.seed do |s|
  s.id = 22
  s.name = 'samba_login'
  s.description = 'Samba Login'
  s.configurable = true
  s.parent_id = 21
  s.display_type = 'text_field'
end

ConfigItem.seed do |s|
  s.id = 23
  s.name = 'samba_password'
  s.description = 'Samba user\'s password'
  s.configurable = true
  s.parent_id = 21
  s.display_type = 'password_field'
end



#FTP
#ConfigItem.seed do |s|
#  s.id = 30
#  s.name = 'ftp'
#  s.description = 'All FTP Related Configuration Items'
#  s.configurable = false
#  s.parent_id = 20
#  s.display_type = nil
#end
#
#ConfigItem.seed do |s|
#  s.id = 31
#  s.name = 'ftp_login'
#  s.description = 'FTP login'
#  s.configurable = true
#  s.parent_id = 30
#  s.display_type = 'text_field'
#end
#
#ConfigItem.seed do |s|
#  s.id = 32
#  s.name = 'ftp_password'
#  s.description = 'FTP user\'s password'
#  s.configurable = true
#  s.parent_id = 30
#  s.display_type = 'password_field'
#end
#
##SFTP
ConfigItem.seed do |s|
  s.id = 40
  s.name = 'ssh'
  s.description = 'All SSH Related Configuration Items'
  s.configurable = false
  s.parent_id = 20
  s.display_type = nil
end

ConfigItem.seed do |s|
  s.id = 31
  s.name = 'ssh_login'
  s.description = 'SSH user'
  s.configurable = true
  s.parent_id = 40
  s.display_type = 'text_field'
end

#ConfigItem.seed do |s|
#  s.id = 32
#  s.name = 'sftp_password'
#  s.description = 'SFTP user\'s password'
#  s.configurable = true
#  s.parent_id = 40
#  s.display_type = 'password_field'
#end

ConfigItem.seed do |s|
  s.id = 33
  s.name = 'ssh_port'
  s.description = 'SSH Port Number'
  s.configurable = true
  s.parent_id = 40
  s.display_type = 'text_field'
end

ConfigItem.seed do |s|
  s.id = 34
  s.name = 'ssh_private_key'
  s.description = 'SSH Private Key'
  s.configurable = true
  s.parent_id = 40
  s.display_type = 'text_area'
end

ConfigItem.seed do |s|
  s.id = 35
  s.name = 'ssh_private_key_password'
  s.description = 'SFTP Private Key Password'
  s.configurable = true
  s.parent_id = 40
  s.display_type = 'password_field'
end

