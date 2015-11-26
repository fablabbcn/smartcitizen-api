# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'smartcitizen'
set :deploy_user, 'deployer'
set :repo_url, "git@github.com:fablabbcn/#{fetch(:application)}.git"
set :branch, "master"
set :full_app_name, "#{fetch(:application)}_#{fetch(:stage)}"
set :deploy_to, "/home/#{fetch(:deploy_user)}/apps/#{fetch(:full_app_name)}"


# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# set :assets_roles, [:app]

# setup repo details
set :scm, :git
set :rbenv_path, "/home/#{fetch(:deploy_user)}/.rbenv"
# set :use_sudo, false

# setup rvm.
set :rbenv_type, :system
set :rbenv_ruby, '2.2.2'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
# set :rbenv_map_bins, %w{rake gem bundle ruby rails}

# Default value for :pty is false
set :pty, false

# how many old releases do we want to keep
set :keep_releases, 5

# files we want symlinking to specific entries in shared.
# set :linked_files, %w{config/database.yml config/application.yml}
set :linked_files, %w{config/database.yml config/application.yml}

# dirs we want symlinking to shared
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
# removed bin https://stackoverflow.com/questions/3744567/typing-rails-console-doesnt-start

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# what specs should be run before deployment is allowed to
# continue, see lib/capistrano/tasks/run_tests.cap
set :tests, []

# which config files should be copied by deploy:setup_config
# see documentation in lib/capistrano/tasks/setup_config.cap
# for details of operations
set(:config_files, %w(
  nginx.conf
  unicorn.rb
  unicorn_init.sh
  log_rotation
  monit
  database.example.yml
))
#

# which config files should be made executable after copying
# by deploy:setup_config
set(:executable_config_files, %w(
  unicorn_init.sh
))

# files which need to be symlinked to other parts of the
# filesystem. For example nginx virtualhosts, log rotation
# init scripts etc.
set(:symlinks, [
  {
    source: "nginx.conf",
    link: "/etc/nginx/sites-enabled/#{fetch(:full_app_name)}"
  },
  {
    source: "unicorn_init.sh",
    link: "/etc/init.d/unicorn_#{fetch(:full_app_name)}"
  },
  {
    source: "log_rotation",
    link: "/etc/logrotate.d/#{fetch(:full_app_name)}"
  },
  {
    source: "monit",
    link: "/etc/monit/conf.d/#{fetch(:full_app_name)}.conf"
  }
])


# this:
# http://www.capistranorb.com/documentation/getting-started/flow/
# is worth reading for a quick overview of what tasks are called
# and when for `cap stage deploy`

namespace :deploy do

  # after :restart, :clear_cache do
  #   on roles(:web), in: :groups, limit: 3, wait: 10 do
  #     # Here we can do anything such as:
  #     # within release_path do
  #     #   execute :rake, 'cache:clear'
  #     # end
  #   end
  # end

  # make sure we're deploying what we think we're deploying
  before :deploy, "deploy:check_revision"
  # only allow a deploy with passing tests to deployed
  before :deploy, "deploy:run_tests"
  # compile assets locally then rsync
  # after 'deploy:symlink:shared', 'deploy:compile_assets_locally'

  after :finishing, 'deploy:cleanup'

  # remove the default nginx configuration as it will tend
  # to conflict with our configs.
  before 'deploy:setup_config', 'nginx:remove_default_vhost'

  # reload nginx to it will pick up any modified vhosts from
  # setup_config
  after 'deploy:setup_config', 'nginx:reload'

  # Restart monit so it will pick up any monit configurations
  # we've added
  after 'deploy:setup_config', 'monit:restart'

  # As of Capistrano 3.1, the `deploy:restart` task is not called
  # automatically.
  after 'deploy:publishing', 'deploy:restart'
end
