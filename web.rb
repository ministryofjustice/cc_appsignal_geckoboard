require 'rubygems'
require 'sinatra'
require_relative 'models/app_signal_api'


APPSIGNAL_SITE_ID = '536133c7b00c7d91fe26727f'
APPSIGNAL_TOKEN   = 'pq4c81K4mHAiiF1BNTx4'
APPSIGNAL_URL     = 'https://appsignal.com/api/'



get '/' do
  "Site-Id: #{APPSIGNAL_SITE_ID}, Token: #{APPSIGNAL_TOKEN}"
end

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




get '/test' do
  x = {
    "item" => [
      {
        "text" => "Past 7 days",
        "value" => "45"
      },
      [
        "3",
        "2",
        "0",
        "0",
        "4",
        "2",
        "1"
      ]
    ]
  }
  x.to_json
end



