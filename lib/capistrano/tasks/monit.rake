namespace :monit do

  desc "Install Monit"
  task :install do
    on roles(:app) do
      sudo "apt-get -y update"
      sudo "apt-get -y install monit"
    end
  end

  %w(start stop restart).each do |task_name|
    desc "#{task_name} Monit"
    task task_name do
      on roles(:app), in: :sequence, wait: 5 do
        sudo "service monit #{task_name}"
      end
    end
  end

  desc "Reload Monit"
  task 'reload' do
    on roles(:app), in: :sequence, wait: 5 do
      sudo "monit reload"
    end
  end

  desc "Monitor everything"
  task :monitor_all do
    on roles(:app) do
      sudo "monit monitor all"
    end
  end

  desc "Unmonitor everything"
  task :unmonitor_all do
    on roles(:app) do
      sudo "monit unmonitor all"
    end
  end
end

before 'deploy', "monit:unmonitor_all"
after 'deploy', 'monit:monitor_all'
