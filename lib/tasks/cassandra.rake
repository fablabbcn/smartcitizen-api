# require 'cassandra'

# namespace :cassandra do
#   task :drop, [:keyspace] do |t, args|
#     if args.keyspace
#       cluster = Cassandra.cluster(hosts: ['localhost'])
#       keyspace = 'system'
#       session  = cluster.connect(keyspace)
#       session.execute("DROP KEYSPACE #{args.keyspace}")
#     end
#   end
# end
