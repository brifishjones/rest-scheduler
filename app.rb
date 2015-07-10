require 'sinatra'
require 'sinatra/activerecord'
require './config/environments' #database configuration
require './models/user'
require './models/shift'

get '/' do
  User.all.to_json
end
