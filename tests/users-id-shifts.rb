require './init'

puts "----------------------------------------------------------------"
puts "GET /users/123/shifts"

run_test "curl -i -H 'authorization: 4:James Young' #{@host}/users/4/shifts"
run_test "curl -i -H 'authorization: 4:James Young' #{@host}/users/5/shifts"
run_test "curl -i -H 'authorization: 4:James Young' #{@host}/users/9999/shifts"
run_test "curl -i -H 'authorization: 1:Alan Smith' #{@host}/users/1/shifts"
