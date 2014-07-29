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
  



  def samples
    url = make_url('samples/errors')
    file = open url
    json_contents = file.read
    hash = JSON.parse(json_contents)
    # File.open('jprint.json', 'w') { |fp| fp.puts(contents) }
    # contents
  end



  private

  def make_url(action)
    "#{@url}/#{@site_id}/#{action}.json?token=#{@token}"
  end


end


