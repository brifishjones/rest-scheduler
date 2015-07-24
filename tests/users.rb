require './init'

puts "----------------------------------------------------------------"
puts "GET /users/"

run_test "curl -i #{@host}/users"
run_test "curl -i -H 'Accept: text/xml' #{@host}/users"
run_test "curl -i -H 'Accept: text/x-yaml' #{@host}/users"
