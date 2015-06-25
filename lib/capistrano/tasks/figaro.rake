# http://blog.staycreativedesign.com/article/setting-up-capistrano3-figaro-rails-4-enviroment-secret/
# https://github.com/ChouAndy/capistrano-figaro-yml

namespace :figaro do
  desc "SCP transfer figaro configuration to the shared folder"
  task :setup do
    on roles(:app) do
      upload! "config/application.yml", "#{shared_path}/config/application.yml", via: :scp
    end
  end

  desc "Symlink application.yml to the release path"
  task :symlink do
    on roles(:app) do
      execute "ln -sf #{shared_path}/config/application.yml #{current_path}/config/application.yml"
    end
  end
end

after "deploy:started", "figaro:setup"
after "deploy:symlink:release", "figaro:symlink"
