GIT_REVISION = `git rev-parse --short HEAD`.chomp || 'revision not found'
GIT_BRANCH = `git rev-parse --abbrev-ref HEAD`.chomp || 'branch not found'

if File.exists?('VERSION')
  VERSION_FILE = `cat VERSION`
else
  VERSION_FILE = 'VERSION file not found'
end
