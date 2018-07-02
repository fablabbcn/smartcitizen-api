if File.exists?('REVISION')
  APP_REVISION = `cat REVISION`
else
  APP_REVISION = 'REVISION file not found'
end

VERSION = File.exists?(File.join(Rails.root, 'VERSION')) ? File.open(File.join(Rails.root, 'VERSION'), 'r') { |f| GIT_VERSION = f.gets.chomp } : nil

