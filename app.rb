require 'sinatra'
require 'sinatra/activerecord'
require './config/environments' #database configuration
require './models/user'
require './models/shift'


before do
  Time.zone = "America/Chicago"
end

# for testing only. Not part of the API
get '/users' do
  format_response(User.all, only: [:id, :name])
end

# for testing only. Not part of the API
get '/shifts' do
  format_response(Shift.all)
end

# As an employee, I want to know when I am working, by being able to see all of the shifts assigned to me.
# GET /users/123/shifts
# curl -i -H "authorization: 4:James Young" -w "\n" https://gentle-brushlands-1205.herokuapp.com/users/4/shifts
get '/users/:id/shifts' do
  halt 403 if authorize != params[:id].to_i || User.where(role: 'manager').find_by_id(params[:id].to_i)
  shifts = Shift.where(employee_id: params[:id]).order(:start_time).order(:end_time)
  halt 200, format_response(no_records_found) if shifts.empty?
  format_response(shifts, only: [:start_time, :end_time])
end

# As an employee, I want to know whom I am working with, by being able see the employees that are working during the same time period as me.
# Returns future shifts
# GET /co-workers/123
# curl -i -H "authorization: 5:Samantha Brown" -w "\n" https://gentle-brushlands-1205.herokuapp.com/co-workers/5
get '/co-workers/:id' do
  halt 403 if authorize != params[:id].to_i || User.where(role: 'manager').find_by_id(params[:id].to_i)
  shifts = Shift.where("start_time >= ?", Time.zone.now).order(:start_time).order(:end_time)
  halt 200, format_response(no_records_found) if shifts.empty?

  my_shifts = shifts.select {|shft| shft.employee_id == params[:id].to_i}
  halt 200, format_response(no_records_found) if my_shifts.empty?

  coworkers = []
  my_shifts.each do |i|
    coworker_shifts = shifts.select {|shft| shft.employee_id != i.employee_id && shft.start_time == i.start_time && shft.end_time == i.end_time}
    halt 200, format_response(no_records_found) if coworker_shifts.empty?
    employees = []
    coworker_shifts.each do |j|
      employees << j.employee.name if j.employee != nil
    end
    coworkers << {'start_time': coworker_shifts.first.start_time.strftime(datetime_format), 'end_time': coworker_shifts.first.end_time.strftime(datetime_format), 'co-workers': employees}
  end

  format_response(coworkers)
end

# As an employee, I want to know how much I worked, by being able to get a summary of hours worked for each week.
# Week starts at midnight on Monday
# Break hours are not substracted from total
# GET /weekly-hours/123
# curl -i -H "authorization: 6:Josh Rollins" -w "\n" https://gentle-brushlands-1205.herokuapp.com/weekly-hours/6
get '/weekly-hours/:id' do
  halt 403 if authorize != params[:id].to_i || User.where(role: 'manager').find_by_id(params[:id].to_i)
  shifts = Shift.where(employee_id: params[:id])
  halt 200, format_response(no_records_found) if shifts.empty?
  format_response(Shift.total_weekly_hours(shifts))
end

# As an employee, I want to be able to contact my managers, by seeing manager contact information for my shifts.
# GET managers/123
# curl -i -H "authorization: 7:Sophia Sanders" -w "\n" https://gentle-brushlands-1205.herokuapp.com/managers/7
get '/managers/:id' do
  halt 403 if authorize != params[:id].to_i || User.where(role: 'manager').find_by_id(params[:id].to_i)
  shifts = Shift.where(employee_id: params[:id]).order(:start_time).order(:end_time)
  halt 200, format_response(no_records_found) if shifts.empty?
  format_response(shifts, {only: [:start_time, :end_time], include: {manager: {only: [:name, :email, :phone]}}})
end

# As a manager, I want to schedule my employees, by creating shifts for any employee.
# POST /shifts
# {
#   manager_id: 3  (defaults to manager creating shift, defaults to manager creating shift)
#   employee_id: 5 (optional)
#   break: .25  (optional)
#   start_time: 2015-08-11 1:15 (in Time.zone, required)
#   end_time: 2015-08-11 5:30 (in Time.zone, required)
# }
# curl -i -H "authorization: 3:Tara DeLong" -w "\n" https://gentle-brushlands-1205.herokuapp.com/shifts -d "employee_id=5&break=0.25&start_time=2015-08-11 1:15&end_time=2015-08-11 5:30"
post '/shifts' do
  halt 403 unless mgr = User.where(role: 'manager').find_by_id(authorize)
  params[:manager_id] = params[:manager_id].nil? ? mgr.id : params[:manager_id]

  shift = Shift.new(params)
  halt 200, format_response(shift_conflict) if shf = Shift.conflict(shift).first
  if shift.save
    status 201
    format_response(shift)
  else
    error 200, format_response(shift.errors)
  end
end


private

# Authorization is passed in the url header in the form id:name
# curl -i -H "authorization: 1:Alan Smith" -w "\n" https://gentle-brushlands-1205.herokuapp.com/shifts
def authorize
  if env['HTTP_AUTHORIZATION'] && env['HTTP_AUTHORIZATION'].split(':').length == 2
    auth_id_user = env['HTTP_AUTHORIZATION'].split(':')
    user = User.where(id: auth_id_user[0]).first
    return user.id if user.name == auth_id_user[1]
  end
  halt 403
end

error 403 do
  format_response([{"403 Forbidden":"Invalid access key or unauthorized to view record"}])
end

error Sinatra::NotFound do
  format_response([{"404 Not Found":"Nothing matches the request URI"}])
end

def no_records_found
  [{"200 OK":"Number of records returned = 0"}]
end

def shift_conflict
  [{"200 OK":"User is already scheduled during this time period"}]
end

def datetime_format
  "%Y-%m-%d %H:%M:%S %z"
end

def format_response(data, args = nil)
  request.accept.each do |type|
    #return data.to_xml(args) if type.downcase.eql? 'text/xml'
    return data.as_json(args).to_xml if type.downcase.eql? 'text/xml'
    return data.as_json(args).to_yaml if type.downcase.eql? 'text/x-yaml'
    return JSON.pretty_generate(data.as_json(args))
  end
end
