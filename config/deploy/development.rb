set :stage, :development
set :branch, `git branch`.match(/\* (\S+)\s/m)[1]
set :server_name, "localhost"

set :repo_url, "git@github.com:fablabbcn/#{fetch(:application)}.git"
set :rails_env, :development
set :unicorn_worker_count, 2
set :enable_ssl, false
# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

server '127.0.0.1', user: 'deployer', roles: %w{app db web}, port: ENV.fetch('ssh_port')

