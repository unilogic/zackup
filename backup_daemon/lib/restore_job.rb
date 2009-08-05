require 'zlib'
require 'archive/tar/minitar'
include Archive::Tar

class RestoreJob

  FIELDS = %w{ hostname ip_address host_type directories exclusions local_backup_dir }.map! { |s| s.to_sym }.freeze
  attr_accessor *FIELDS
  @@settings = DaemonKit::Config.load('settings').to_h

  DEFAULTS = { 
    :data => nil, 
    :download_dir_base => @@settings['download_dir_base'], 
    :download_url_base => @@settings['download_url_base'], 
    :backup_dir => nil
  }.freeze

  def initialize(args = {})
    args = args ? args.merge(DEFAULTS).merge(args) : DEFAULTS
  
    FIELDS.each do |attr|
      args.each_pair do | key, value |
          instance_variable_set("@#{attr}", args[attr])
      end
    end
  end
  
  def run
    unless self.data
      return 1, "RestoreJob, the data field must be specified"
    end
    unless self.backup_dir
      return 1, "RestoreJob, the backup_dir field must be specified"
    end
    unless self.download_dir_base
      return 1, "RestoreJob, the download_dir_base field must be specified"
    end
    unless self.download_url_base
      return 1, "RestoreJob, the download_url_base field must be specified"
    end
    
    restore_items = []
    data.each do |item| 
      restore_items << item.keys.first + '/' + item.values.first
    end
    
    tgz = build_tgz(restore_items)
  end
  
  private 
  
  def build_tgz(items)
     o = [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
    rand = (0..55).map{ o[rand(o.length)]  }.join
    tgz_filename = self.download_dir_base + '/' + rand + '.tgz'
    Dir.chdir(self.backup + '/.zfs/snapshot') do
      tgz = Zlib::GzipWriter.new(File.open(tgz_filename, 'wb'))
      Minitar.pack(items, tgz)
    end
    return 0, tgz_filename
  end
  
end