GIT_REVISION = `git rev-parse --short HEAD` || 'revision not found'.chomp
GIT_BRANCH = `git rev-parse --abbrev-ref HEAD` || 'branch not found'.chomp

if File.exists?('VERSION')
  VERSION_FILE = `cat VERSION`
else
  VERSION_FILE = 'VERSION file not found'
end
