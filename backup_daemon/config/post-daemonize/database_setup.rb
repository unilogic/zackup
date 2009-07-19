db_yaml = DaemonKit::Config.load('database')
DaemonKit.logger.info "Setting up ActiveRecord Connection"

ActiveRecord::Base.establish_connection(db_yaml.to_h)