if defined?(Spring)
  Spring.after_fork do
    require 'cassandra'
    cluster = Cassandra.cluster(hosts: [ ENV['cassandra_host_ip'] ])
    $cassandra ||= cluster.connect(ENV['cassandra_keyspace'])
  end
else
  require 'cassandra'
  cluster = Cassandra.cluster(hosts: [ ENV['cassandra_host_ip'] ])
  $cassandra ||= cluster.connect(ENV['cassandra_keyspace'])
end
