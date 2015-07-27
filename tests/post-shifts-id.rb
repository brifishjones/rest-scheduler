require './init'

puts "----------------------------------------------------------------"
puts "POST /shifts/id"

test_date = '2016-01-02'

puts "change the time"
run_test "curl -i -H 'authorization: 3:Tara DeLong' #{@host}/shifts/1 -d 'start_time=2015-07-01 2:00&end_time=2015-07-01 5:30'"
puts "change the employee"
run_test "curl -i -H 'authorization: 3:Tara DeLong' #{@host}/shifts/1 -d 'employee_id=10'"
puts "clear the employee"
run_test "curl -i -H 'authorization: 3:Tara DeLong' #{@host}/shifts/1 -d 'employee_id=0'"
