namespace :banned_words do
  desc "SCP transfer banned_words configuration to the shared folder"
  task :setup do
    on roles(:app) do
      upload! "config/banned_words.production.yml", "#{shared_path}/config/banned_words.yml", via: :scp
    end
  end

  desc "Symlink application.yml to the release path"
  task :symlink do
    on roles(:app) do
      execute "ln -sf #{shared_path}/config/banned_words.yml #{current_path}/config/banned_words.yml"
    end
  end
end

after "deploy:started", "banned_words:setup"
after "deploy:symlink:release", "banned_words:symlink"
