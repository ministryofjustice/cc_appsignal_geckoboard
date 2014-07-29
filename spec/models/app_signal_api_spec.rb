require 'rspec'
require_relative '../../models/app_signal_api'


describe AppSignalApi do

  describe '.new' do
    it 'should load config values' do
      api = AppSignalApi.new
      pp api
      expect(api).to be_instance_of(AppSignalApi)
    end
  end



end

