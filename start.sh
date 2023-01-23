export APP_ENV=$NOTES_ENV
export RACK_ENV=$NOTES_ENV
export RAILS_ENV=$NOTES_ENV
[[ -z "$DATABASE_URL" ]] && unset DATABASE_URL

bundle exec rake apply_db_config

bundle exec rake db:prepare

rackup --host 0.0.0.0 -p 80