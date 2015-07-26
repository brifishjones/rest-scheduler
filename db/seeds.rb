# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

# create managers and employees
User.create(name: 'Alan Smith', role: 'manager', email: 'alan-smith@mycompany.com', phone: '555-432-1234')
User.create(name: 'Bethany Huebner', role: 'manager', email: 'bhuebner@mycompany.com', phone: '555-432-2345')
User.create(name: 'Tara DeLong', role: 'manager', email: 'taradelong@mycompany.com', phone: '555-432-3456')

User.create(name: 'James Young', role: 'employee', email: 'jim-young@yahoo.com', phone: '666-312-9999')
User.create(name: 'Samantha Brown', role: 'employee', email: 'sabrown55@gmail.com')
User.create(name: 'Josh Rollins', role: 'employee', email: 'josh@mydomain.com', phone: '777-612-8899')
User.create(name: 'Sophia Sanders', role: 'employee', phone: '543-654-2222')
User.create(name: 'Zach Tobias', role: 'employee', email: 'zacht@mydomain.com', phone: '445-543-7777')
User.create(name: 'Eva Fisher', role: 'employee', email: 'eva-fisher@mydomain.com', phone: '345-345-3456')
User.create(name: 'Bert Large', role: 'employee', email: 'burt-large@mydomain.com')
User.create(name: 'Erin Hammond', role: 'employee', email: 'erin-h@mydomain.com', phone: '222-333-4445')
User.create(name: 'Janet Titian', role: 'employee', email: 'jtitian90@gmail.com', phone: '777-345-9998')
User.create(name: 'Adam Gregory', role: 'employee', email: 'adam.gregory@gmail.com', phone: '888-123-7776')

Time.zone = "America/Chicago"
# create morning and evening shifts 
def parse_time(date, time, timezone = "America/Chicago")
  ActiveSupport::TimeZone.new(timezone).parse(date.strftime("%Y-%m-%d") + ' ' + time) 
end

def create_shift(date, morning, mgr_id, *emp_ids, brk)
  start_time = morning ? '6:00' : '14:30' 
  end_time = morning ? '14:30' : '23:00' 

  emp_ids.each do |eid|
    Shift.create(manager_id: mgr_id, employee_id: eid, break: brk, start_time: parse_time(date, start_time), end_time: parse_time(date, end_time))
  end
end

(Date.today() - 3..Date.today() + 17).each do |date|
  if date.wday == 0 || date.wday == 6   # weekend
    create_shift(date, true, 3, *[8, nil], 0.5)
    create_shift(date, false, 3, *[9, nil], 0.5)
    if date.wday == 0   # create shifts that starts on Sunday, ends on Monday
      Shift.create(manager_id: 3, employee_id: 10, break: 0.75, start_time: parse_time(date, '19:00'), end_time: parse_time(date + 1.day, '3:30'))
      Shift.create(manager_id: 3, employee_id: 11, break: 0.75, start_time: parse_time(date, '19:00'), end_time: parse_time(date + 1.day, '3:30'))
    end
  else   # weekday
    create_shift(date, true, 1, *[4, 5, nil], 0.5) 
    create_shift(date, false, 2, *[6, 7, nil], 0.5) 
  end
end
