export APP_ENV=$NOTES_ENV
export RACK_ENV=$NOTES_ENV
export RAILS_ENV=$NOTES_ENV

[[ -z "$DATABASE_URL" ]] && unset DATABASE_URL
[[ -z "$BIND_HOST" ]] && BIND_HOST="0.0.0.0"
[[ -z "$BIND_PORT" ]] && BIND_PORT="80"
[[ -z "$DB_IS_AZURE" || "${DB_IS_AZURE,,}" == "false" ]] && DB_IS_AZURE="false"

bundle exec rake apply_db_config

bundle exec rake db:prepare

rackup --host $BIND_HOST -p $BIND_PORT