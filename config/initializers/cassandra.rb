if defined?(Spring)
  Spring.after_fork do
    require 'cassandra'
    cluster = Cassandra.cluster
    $cassandra ||= cluster.connect('smart_citizen_development')
  end
else
  require 'cassandra'
  cluster = Cassandra.cluster
  $cassandra ||= cluster.connect('smart_citizen_development')
end
