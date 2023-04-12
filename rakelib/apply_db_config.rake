desc 'Apply database configuration'
task :apply_db_config do
    APP_ROOT = File.expand_path("..", __dir__)

    def env_vars_present?
        required_keys = ["DB_ADAPTER", "DB_HOST", "DB_PORT", "DB_DATABASE", "DB_USERNAME", "DB_PASSWORD"]
        required_keys.all? { |key| !ENV[key].nil? && !ENV[key].empty? }
    end
    
    # mirroring Sinatra behavior - https://sinatrarb.com/configuration.html#environment---configurationdeployment-environment
    cur_env = ENV["RACK_ENV"] || "development"

    puts "Using \"#{cur_env}\" environment."
    
    if !ENV["DATABASE_URL"].nil? 
        puts "DATABASE_URL was specified. This will take precedence over other settings."
        # Trigger override by overwriting database.yml with empty content
        # https://guides.rubyonrails.org/v4.1/configuring.html#connection-preference
        File.write(File.join(APP_ROOT, 'config', 'database.yml'), "")
        next
    end

    unless env_vars_present?
        puts "Database configuration was not provided, so a local sqlite database will be used."
        next
    end

    config = YAML.load_file(File.join(APP_ROOT, 'config', 'database.yml'), aliases: true)

    puts "Applying database configuration for current environment (#{cur_env})..."

    config[cur_env].delete("pool")
    config[cur_env].delete("write_timeout")
    config[cur_env].delete("read_timeout")

    config[cur_env]["adapter"] = ENV["DB_ADAPTER"]
    config[cur_env]["host"] = ENV["DB_HOST"]
    config[cur_env]["port"] = ENV["DB_PORT"]
    config[cur_env]["database"] = ENV["DB_DATABASE"]
    config[cur_env]["username"] = ENV["DB_USERNAME"]
    config[cur_env]["password"] = ENV["DB_PASSWORD"]
    config[cur_env]["azure"] = ENV["DB_IS_AZURE"].downcase == "true"

    File.write(File.join(APP_ROOT, 'config', 'database.yml'), config.to_yaml)
end