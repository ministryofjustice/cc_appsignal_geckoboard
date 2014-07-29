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



  describe '#analyse_hash' do

    let(:today)   { Date.today }
    let(:api)     { AppSignalApi.new }

    context 'more than 7 days of errors' do
      it 'should return a hash summarising the number day by day' do
        error_times = [
            make_date_time(0, 3, 56, 45),
            make_date_time(0, 5, 45, 3),
            make_date_time(1, 15, 45, 3),
            make_date_time(1, 16, 45, 3),
            make_date_time(2, 5, 45, 3),
            make_date_time(3, 5, 45, 3),
            make_date_time(4, 5, 45, 3),
            make_date_time(5, 5, 45, 3),
            make_date_time(6, 5, 45, 3),
            make_date_time(7, 5, 45, 3),
            make_date_time(8, 5, 45, 3)
        ]
        hash = make_hash_from_error_times(error_times)
        expected_result = construct_result(7, 9, [1,1,1,1,1,2,2])
        expect(api.send(:analyse_hash)).to eq expected_result
      end
    end
  end
end


def construct_result(num_days, num_errors, errors_per_day)
  hash = {
    'item' => [
        { 'text' => "Past #{num_days} days", "value" => num_errors.to_s},
        errors_per_day.map(&:to_s)
    ]
  }
  hash.to_json

end


def make_hash_from_error_times(error_times)
  log_entries = []
  error_times.each do |et|
    hash = {
      'id'  => '53d42f00776f7272a7b20500',
      'action' => 'ClaimController#download',
      'path' => '/accelerated-possession-eviction/download',
      'duration' => 1.584233,
      'status' => nil,
      'time' => et.to_i,
      'is_exception' => true,
      'exception' => {'name' => 'NoMethodError'}
    }
    log_entries << hash
  end
  { 'count' => 52, 'log_entries' => log_entries}

end




def make_date_time(days_ago, h, m, s)
  date = Date.today - days_ago
  time = date.to_time
  time += ((h * 60 * 60) + (m * 60) + s)
  time
end

