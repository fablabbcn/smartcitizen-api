if File.exists?('REVISION')
  APP_REVISION = `cat REVISION`
else
  APP_REVISION = 'REVISION file not found'
end

if File.exists?('VERSION')
  VERSION_FILE = `cat VERSION`
else
  VERSION_FILE = 'VERSION file not found'
end
