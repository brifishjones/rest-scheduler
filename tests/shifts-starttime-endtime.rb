require './init'

puts "----------------------------------------------------------------"
puts "GET /shifts/2016-01-01T6:00/2015-12-01T0:00"

run_test "curl -i -H 'authorization: 2:Bethany Huebner' #{@host}/shifts/2015-08-01T8:00/2015-09-01T23:00"
