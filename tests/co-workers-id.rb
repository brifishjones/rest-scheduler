require './init'

puts "----------------------------------------------------------------"
puts "GET /co-workers/123"

run_test "curl -i -H 'authorization: 5:Samantha Brown' #{@host}/co-workers/5"
run_test "curl -i -H 'authorization: 10:Bert Large' #{@host}/co-workers/10"
