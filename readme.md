# REST Scheduler API

Framework used:

- Ruby (2.2.0)
- Sinatra (1.4.6)
- ActiveRecord (4.2.3)
- Postgres (9.4.4)

Project is deployed at: https://gentle-brushlands-1205.herokuapp.com

Use `curl` to view the API not a browser. For example:<br>
`curl -i -w "\n" https://gentle-brushlands-1205.herokuapp.com/users`

## Requirements

The API must follow REST specification:

- POST should be used to create
- GET should be used to read
- PUT should be used to update (and optionally to create)
- DELETE should be used to delete

Additional methods can be used for expanded functionality.

The API should include the following roles:

- employee (read)
- manager (write)

The `employee` will have much more limited access than a `manager`. The specifics of what each role should be able to do is listed below in [User Stories](#user-stories).

## Data Types

All data structures use the following types:

| type   | description |
| ------ | ----------- |
| int    | a integer number |
| float  | a floating point number |
| string | a string |
| bool   | a boolean |
| id     | a unique identifier |
| fk     | a reference to another id |
| date   | an RFC 2822 formatted date string |

## Data Structures

### User

| field       | type |
| ----------- | ---- |
| id          | id |
| name        | string |
| role        | string |
| email       | string |
| phone       | string |
| created_at  | date |
| updated_at  | date |

The `role` must be either `employee` or `manager`. At least one of `phone` or
`email` must be defined.

### Shift

| field       | type |
| ----------- | ---- |
| id          | id |
| manager_id  | fk |
| employee_id | fk |
| break       | float |
| start_time  | date |
| end_time    | date |
| created_at  | date |
| updated_at  | date |

Both `start_time` and `end_time` are required. Unless defined, the `manager_id`
should always default to the manager that created the shift. Any shift without
an `employee_id` will be visible to all employees.

## User stories

**Please note that this not intended to be a CRUD application.** Only the functionality described by the user stories should be exposed via the API.

-  As an employee, I want to know when I am working, by being able to see all of the shifts assigned to me.
-  As an employee, I want to know who I am working with, by being able see the employees that are working during the same time period as me.
-  As an employee, I want to know how much I worked, by being able to get a summary of hours worked for each week.
-  As an employee, I want to be able to contact my managers, by seeing manager contact information for my shifts.

-  As a manager, I want to schedule my employees, by creating shifts for any employee.
-  As a manager, I want to see the schedule, by listing shifts within a specific time period.
-  As a manager, I want to be able to change a shift, by updating the time details.
-  As a manager, I want to be able to assign a shift, by changing the employee that will work a shift.
-  As a manager, I want to contact an employee, by seeing employee details.

### Development process notes:

Time zone is a factor even though the database stores times as Universal Time (Greenwich mean time). The server's system time zone will be used if Time.parse is called. This could be a problem if a cloud service is utilized in a different time zone than the users'. So to keep everyone on the same page it's necessary to agree on a base time zone (Central time in this example) and call Time.zone.parse to process start and end times. Although it is an API convention to return times in UTC, in this project times will be returned in Central time.

At least one of phone or email must be defined. This actually makes the problem more difficult. Instead of a simple validation additional logic will need to be added to models/user.rb:
- `validates :email, presence: true, unless: ->(user){user.phone.prsent?}`
- `validates :phone, presence: true, unless: ->(user){user.email.present?}`

Unless defined, the manager_id should always default to the manager that created the shift. The API call will need to know the manager id. Will be passed in the header.

The employee will have much more limited access than a manager. The API call will need a way to validate which user is making the call. Normally an API key and shared secret would be used to identify which user is making the call but for simplicity the `user_id` and `user_name` will be passed in the header for each API call made (e.g. 1:Alan Smith)

A RESTful API should be stateless. Each request should come with an authentication credential and not depend on cookies or sessions.

Return values are in json but xml and yaml formats are supported as well. Add `-H "Accept: text/xml"` to the request header:<br>
`curl -i -H "Accept: text/xml" https://gentle-brushlands-1205.herokuapp.com/users`<br>
`curl -i -H "Accept: text/x-yaml" https://gentle-brushlands-1205.herokuapp.com/users`

Database is seeded with values by running `heroku run rake db:migrate`.

## API 

As an employee, I want to know when I am working, by being able to see all of the shifts assigned to me.<br>
GET /users/123/shifts<br>
`curl -i -H "authorization: 4:James Young" -w "\n" https://gentle-brushlands-1205.herokuapp.com/users/4/shifts` 

As an employee, I want to know whom I am working with, by being able see the employees that are working during the same time period as me.<br>
Returns future shifts<br>
GET /co-workers/123<br>
`curl -i -H "authorization: 5:Samantha Brown" -w "\n" https://gentle-brushlands-1205.herokuapp.com/co-workers/5`

As an employee, I want to know how much I worked, by being able to get a summary of hours worked for each week.<br>
Week starts at midnight on Monday<br>
Break hours are not substracted from total<br>
GET /weekly-hours/123<br>
`curl -i -H "authorization: 6:Josh Rollins" -w "\n" https://gentle-brushlands-1205.herokuapp.com/weekly-hours/6`

As an employee, I want to be able to contact my managers, by seeing manager contact information for my shifts.<br>
GET managers/123<br>
`curl -i -H "authorization: 7:Sophia Sanders" -w "\n" https://gentle-brushlands-1205.herokuapp.com/managers/7`

As a manager, I want to schedule my employees, by creating shifts for any employee.<br>
POST /shifts<br>
- manager_id: 3  (defaults to manager creating shift)
- employee_id: 5 (optional)
- break: .25  (optional)
- start_time: 2015-08-11 1:15 (in Time.zone, required)
- end_time: 2015-08-11 5:30 (in Time.zone, required)

`curl -i -H "authorization: 3:Tara DeLong" -w "\n" https://gentle-brushlands-1205.herokuapp.com/shifts -d "employee_id=5&break=0.25&start_time=2015-08-11 1:15&end_time=2015-08-11 5:30"`

As a manager, I want to see the schedule, by listing shifts within a specific time period.<br>
GET /shifts/2015-08-01T8:00/2015-09-01T23:00<br>
`curl -i -H "authorization: 2:Bethany Huebner" -w "\n" https://gentle-brushlands-1205.herokuapp.com/shifts/2015-08-01T8:00/2015-09-01T23:00`

As a manager, I want to be able to change a shift, by updating the time details.<br>
As a manager, I want to be able to assign a shift, by changing the employee that will work a shift.<br>
POST /shifts/123<br>
`curl -i -H "authorization: 1:Alan Smith" http://gentle-brushlands-1205.herokuapp.com/shifts/123 -d "start_time=2015-08-11 8:15&end_time=2015-08-11 12:30"`<br>
`curl -i -H "authorization: 1:Alan Smith" http://gentle-brushlands-1205.herokuapp.com/shifts/123 -d "employee_id=7"`<br>
`curl -i -H "authorization: 1:Alan Smith" http://gentle-brushlands-1205.herokuapp.com/shifts/123 -d "employee_id=0"`  to mark shift unfilled

As a manager, I want to contact an employee, by seeing employee details.<br>
GET /employees/123<br>
`curl -i -H "authorization: 2:Bethany Huebner" -w "\n" https://gentle-brushlands-1205.herokuapp.com/employees/5`


For testing only. Not part of the API

GET /users<br>
`curl -i -w "\n" https://gentle-brushlands-1205.herokuapp.com/users`<br>
`curl -i -H "Accept: text/xml" https://gentle-brushlands-1205.herokuapp.com/users`<br>
`curl -i -H "Accept: text/x-yaml" https://gentle-brushlands-1205.herokuapp.com/users`

GET /shifts<br>
`curl -i -w "\n" https://gentle-brushlands-1205.herokuapp.com/shifts`

## Tests 

Tests are simply ruby files containing curl commands for each of the stories. To run tests:
- copy the contents of the tests directory to your local computer 
- `cd tests`
- run a given test (e.g. `ruby managers-id.rb`)

Note: if running a server locally append `localhost` to the test (e.g. `ruby managers-id.rb localhost`)
