require 'yaml'
require 'open-uri'
require 'json'

class AppSignalApi


  def initialize
    raise "Environment Variable APPSIGNAL_SITE_ID not set"  if ENV['APPSIGNAL_SITE_ID'].nil?
    raise "Environment Variable APPSIGNAL_TOKEN not set"    if ENV['APPSIGNAL_TOKEN'].nil?
    raise "Environment Variable APPSIGNAL_BASE_URL not set" if ENV['APPSIGNAL_BASE_URL'].nil?

    @site_id = ENV['APPSIGNAL_SITE_ID']
    @token   = ENV['APPSIGNAL_TOKEN']
    @url     = ENV['APPSIGNAL_BASE_URL']
  end
  

  # this is a debugging method which simply returns the data from appsignal - not used by geckoard
  def appsignal
    get_appsignal_data
  end


  # gets the data from appsignal and transforms it into a json hash for geckoboard
  def errors
    hash = JSON.parse(get_appsignal_data)
    result = analyse_hash(hash)
  end



  private

  def get_appsignal_data
    url = make_url('samples/errors')
    file = open url
    json_contents = file.read
  end

  def make_url(action)
    "#{@url}/#{@site_id}/#{action}.json?token=#{@token}"
  end

  def analyse_hash(hash)
    num_errors_per_day = {}
    total_errors = 0
    6.downto(0) { |i| num_errors_per_day[(Date.today - i).to_time] = 0 }
    dates = num_errors_per_day.keys

    hash['log_entries'].each do | log |
      log_date = determine_date(dates, log['time'])
      unless log_date.nil?
        total_errors += 1
        num_errors_per_day[log_date] += 1
      end
    end
    { 
      'item' => 
      [
        { 
          'text' => "Past #{num_errors_per_day.size} days",
          'value' => total_errors.to_s
        },
        num_errors_per_day.values.map(&:to_s)
      ]
      }.to_json
  end


  # determines which date the secs since epoch belongs to.  returns nil if before the first date
  def determine_date(date_array, secs_since_epoch)
    t = Time.at(secs_since_epoch)
    return nil if t < date_array.first
    if t > date_array.last + 86400
      raise "Given time of #{t.strftime('%Y-%m-%d %H:%M:%S')} is more than 24 hours after last date in period (#{date_array.last.strftime('%Y-%m-%d %H:%M:%S')})"
    end

    date_array.each_with_index do |date, i|
      if t < date
        return date_array[i - 1]
      end
    end
    # if we're here, it must be the last date
    date_array.last
  end



end


