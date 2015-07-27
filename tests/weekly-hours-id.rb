require './init'

puts "----------------------------------------------------------------"
puts "GET /weekly-hours/123"

run_test "curl -i -H 'authorization: 6:Josh Rollins' #{@host}/weekly-hours/6"
run_test "curl -i -H 'authorization: 9:Eva Fisher' #{@host}/weekly-hours/9"
run_test "curl -i -H 'authorization: 10:Bert Large' #{@host}/weekly-hours/10"
