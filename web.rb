require 'rubygems'
require 'sinatra'
require_relative 'models/app_signal_api'


get '/samples' do
  @sample_hash = AppSignalApi.new.samples
  haml :samples
end

get '/appsignal' do
  AppSignalApi.new.appsignal
end


get '/errors' do
  AppSignalApi.new.errors
end



