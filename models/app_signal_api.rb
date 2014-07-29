require 'yaml'
require 'open-uri'
require 'json'

class AppSignalApi


  def initialize
    config_file = File.expand_path(File.dirname(__FILE__) + '/../app_signal_api_config.yml')
    config = YAML.load_file(config_file)
    @site_id = config['appsignal']['site_id']
    @token = config['appsignal']['token']
    @url = config['appsignal']['url']
  end
  



  def errors
    url = make_url('samples/errors')
    file = open url
    json_contents = file.read
    hash = JSON.parse(json_contents)
    result = analyse_hash(hash)
  end



  private

  def make_url(action)
    "#{@url}/#{@site_id}/#{action}.json?token=#{@token}"
  end

  def analyse_hash(hash)
    num_errors_per_day = {}
    total_errors = 0
    6.downto(0) { |i| num_errors_per_day[(Date.today - i).to_time] = 0 }
    dates = num_errors_per_day.keys

    hash['log_entries'].each do | log |
      log_date = determine_date[dates, log['time']]
      unless log_date.nil?
        total_errors += 1
        num_errors_per_day[log_date] += 1
      end
    end
  end


  # determines which date the secs since epoch belongs to.  returns nil if before the first date
  def determine_date(date_array, secs_since_epoch)
    t = Time.at(secs_since_epoch)
    return nil if t < date_array.first

    # walk up the array until you get to ta date greater than the time, and then return that date.

  end




  def start_of_day(date)
    date.to_time
  end


end


