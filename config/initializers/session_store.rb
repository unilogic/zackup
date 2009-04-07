# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_zackup_session',
  :secret      => '478099d595cf679151c5e6069c6f687a655b38313a078aef0e804aa34d2aae022e4113ce9d8830832bedee9ff3975d2c18fe7caf36afe65913cca0a1d32b50ff'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
