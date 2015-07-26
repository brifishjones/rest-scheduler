require './init'

puts "----------------------------------------------------------------"
puts "GET /managers/123"

run_test "curl -i -H 'authorization: 7:Sophia Sanders' #{@host}/managers/7"
