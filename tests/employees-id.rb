require './init'

puts "----------------------------------------------------------------"
puts "GET /employees/123"

run_test "curl -i -H 'authorization: 2:Bethany Huebner' #{@host}/employees/5"
run_test "curl -i -H 'authorization: 2:Bethany Huebner' #{@host}/employees/6"
run_test "curl -i -H 'authorization: 2:Bethany Huebner' #{@host}/employees/2"
run_test "curl -i -H 'authorization: 2:Bethany Huebner' #{@host}/employees/9999"
