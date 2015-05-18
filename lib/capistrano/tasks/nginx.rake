namespace :nginx do

  desc "Install nginx"
  task :install do
    on roles(:web) do
      sudo "apt-get -y update"
      sudo "apt-get -y install nginx"
    end
  end
  # after "deploy:install", "nginx:install"

  %w(start stop restart reload).each do |task_name|
    desc "#{task } Nginx"
    task task_name do
      on roles(:web), in: :sequence, wait: 5 do
        sudo "/etc/init.d/nginx #{task_name}"
      end
    end
  end

  desc "Remove default Nginx Virtual Host"
  task "remove_default_vhost" do
    on roles(:web) do
      if test("[ -f /etc/nginx/sites-enabled/default ]")
      sudo "rm /etc/nginx/sites-enabled/default"
      puts "removed default Nginx Virtualhost"
      else
        puts "No default Nginx Virtualhost to remove"
      end
    end
  end
end
