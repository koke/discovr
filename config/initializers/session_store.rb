# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_discovr_session',
  :secret      => '497e67ce6ff0346b2b9053f771c802bb853d2e09709d9844a17bc20f2b8aa3f736aa9fdb264c8f547c1963e2ae0341341cebe88f9a722580b2f949595553efd0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
