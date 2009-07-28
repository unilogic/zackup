# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090728012650) do

  create_table "config_items", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "configurable"
    t.integer  "parent_id"
    t.string   "display_type"
  end

  create_table "host_configs", :force => true do |t|
    t.integer  "host_id",                       :null => false
    t.integer  "config_item_id",                :null => false
    t.text     "value",          :limit => 255, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "host_configs", ["host_id", "config_item_id"], :name => "index_host_configs_on_host_id_and_config_item_id", :unique => true

  create_table "hosts", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", :force => true do |t|
    t.integer  "backup_node_id"
    t.integer  "scheduler_node_id"
    t.integer  "scheduler_job_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "data",              :limit => 255
    t.integer  "host_id"
    t.integer  "schedule_id"
    t.datetime "finished_at"
    t.datetime "start_at"
    t.string   "operation"
  end

  create_table "nodes", :force => true do |t|
    t.string   "ip_address"
    t.string   "hostname"
    t.string   "description"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "backup_node"
    t.boolean  "scheduler_node"
    t.datetime "last_seen"
  end

  create_table "retention_policies", :force => true do |t|
    t.integer  "schedule_id"
    t.integer  "keep_min_time"
    t.text     "min_time_type"
    t.integer  "keep_max_time"
    t.text     "max_time_type"
    t.integer  "keep_max_versions"
    t.integer  "keep_min_versions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schedules", :force => true do |t|
    t.integer  "host_id",        :null => false
    t.date     "start_date",     :null => false
    t.string   "repeat",         :null => false
    t.string   "every",          :null => false
    t.string   "on"
    t.time     "stop"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "status"
    t.string   "start_time"
    t.integer  "backup_node_id"
    t.datetime "last_finish"
    t.datetime "last_start"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.text     "settings"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login",                            :null => false
    t.string   "crypted_password",                 :null => false
    t.string   "password_salt",                    :null => false
    t.string   "persistence_token",                :null => false
    t.string   "first_name",                       :null => false
    t.string   "last_name",                        :null => false
    t.string   "email",                            :null => false
    t.integer  "login_count",       :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
  end

  add_index "users", ["last_request_at"], :name => "index_users_on_last_request_at"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"

end
