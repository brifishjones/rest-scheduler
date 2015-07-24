require 'sinatra'
require 'sinatra/activerecord'
require './config/environments' #database configuration
require './models/user'
require './models/shift'

# for testing only. Not part of the API
get '/users' do
  format_response(User.all, only: [:id, :name])
end

# for testing only. Not part of the API
get '/shifts' do
  format_response(Shift.all)
end


private

# Authorization is passed in the url header in the form id:name
# curl -i -H "authorization: 1:Alan Smith" -w "\n" localhost:4567/shifts
def authorize
  if env['HTTP_AUTHORIZATION'] && env['HTTP_AUTHORIZATION'].split(':').length == 2
    auth_id_user = env['HTTP_AUTHORIZATION'].split(':')
    user = User.where(id: auth_id_user[0]).first
    return user.id if user.name == auth_id_user[1]
  end
  halt 403
end

error 403 do
  '{"403 Forbidden":"Invalid access key or unauthorized to view record"}'
end

error 500 do
  '{"500 Not Found":"Record does not exist"}'
end

def format_response(data, args = nil)
  request.accept.each do |type|
    return data.to_xml(args) if type.downcase.eql? 'text/xml'
    return data.as_json(args).to_yaml if type.downcase.eql? 'text/x-yaml'
    return JSON.pretty_generate(data.as_json(args))
  end
end
