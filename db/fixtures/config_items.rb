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

ConfigItem.seed do |s|
  s.id = 4
  s.name = 'status'
  s.description = 'Status of Host'
  s.configurable = false
  s.parent_id = 1
  s.display_type = nil
end

# Host Type
ConfigItem.seed do |s|
  s.id = 20
  s.name = 'host_type'
  s.description = 'Type of Host, Samba, FTP, SSH, etc'
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
  s.name = 'Samba Password'
  s.description = 'Samba user\'s password'
  s.configurable = true
  s.parent_id = 21
  s.display_type = 'password_field'
end

#FTP
ConfigItem.seed do |s|
  s.id = 30
  s.name = 'ftp'
  s.description = 'All FTP Related Configuration Items'
  s.configurable = false
  s.parent_id = 20
  s.display_type = nil
end

ConfigItem.seed do |s|
  s.id = 31
  s.name = 'FTP Password'
  s.description = 'FTP user\'s password'
  s.configurable = true
  s.parent_id = 30
  s.display_type = 'password_field'
end

