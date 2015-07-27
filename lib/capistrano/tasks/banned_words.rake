namespace :banned_words do
  desc "Symlink words.yml"
  task :symlink do
    system "mkdir -p #{shared_path}/config"
    on roles(:all) do
      upload! "config/banned_words.production.yml", "#{shared_path}/config/banned_words.yml"
    end
    system "ln -sf #{shared_path}/config/banned_words.yml #{release_path}/config/banned_words.yml"
  end
  after "deploy:symlink:release", "banned_words:symlink"
end
