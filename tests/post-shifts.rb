require './init'

puts "----------------------------------------------------------------"
puts "POST /shifts"

test_date = '2016-01-01'

puts "create a shift"
run_test "curl -i -H 'authorization: 3:Tara DeLong' #{@host}/shifts -d 'employee_id=5&break=0.25&start_time=#{test_date} 1:15&end_time=#{test_date} 5:30'"
puts "create a shift and assign to another manager"
run_test "curl -i -H 'authorization: 3:Tara DeLong' #{@host}/shifts -d 'manager_id=2&employee_id=6&break=0.25&start_time=#{test_date} 1:15&end_time=#{test_date} 5:30'"
puts "create a shift scheduling conflict"
run_test "curl -i -H 'authorization: 3:Tara DeLong' #{@host}/shifts -d 'employee_id=5&break=0.25&start_time=#{test_date} 1:15&end_time=#{test_date} 5:30'"
puts "create a shift that starts at the same time another one ends"
run_test "curl -i -H 'authorization: 3:Tara DeLong' #{@host}/shifts -d 'employee_id=5&break=0.25&start_time=#{test_date} 5:30&end_time=#{test_date} 7:30'"
puts "create a shift that ends at the same time another one starts"
run_test "curl -i -H 'authorization: 3:Tara DeLong' #{@host}/shifts -d 'break=0.25&start_time=#{test_date} 0:30&end_time=#{test_date} 1:15'"
puts "create a shift that has a badly formatted start time"
run_test "curl -i -H 'authorization: 3:Tara DeLong' #{@host}/shifts -d 'employee_id=6&break=0.25&start_time=abcd&end_time=#{test_date} 5:30'"
puts "create a shift where the end time is before the start time"
run_test "curl -i -H 'authorization: 3:Tara DeLong' #{@host}/shifts -d 'employee_id=5&break=0.25&start_time=#{test_date} 10:30&end_time=#{test_date} 10:29'"
puts "create a shift where the start time is the same as the end time"
run_test "curl -i -H 'authorization: 3:Tara DeLong' #{@host}/shifts -d 'employee_id=5&break=0.25&start_time=#{test_date} 10:30&end_time=#{test_date} 10:30'"
puts "create a shift that has an invalid manager id"
run_test "curl -i -H 'authorization: 3:Tara DeLong' #{@host}/shifts -d 'manager_id=10&break=0.25&start_time=#{test_date} 8:00&end_time=#{test_date} 9:00'"
puts "create a shift that has an invalid employee id"
run_test "curl -i -H 'authorization: 3:Tara DeLong' #{@host}/shifts -d 'employee_id=2&break=0.25&start_time=#{test_date} 8:00&end_time=#{test_date} 9:00'"
