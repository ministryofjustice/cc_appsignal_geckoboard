require 'rspec'
require_relative '../../models/app_signal_api'


describe AppSignalApi do

  let(:api)     { AppSignalApi.new }

  describe '.new' do
    it 'should load config values' do
      api = AppSignalApi.new
      expect(api).to be_instance_of(AppSignalApi)
    end
  end


  context 'private methods' do

    describe '#determine_date' do
      let(:date_array) do
        [
          Date.new(2014, 7, 21).to_time,
          Date.new(2014, 7, 22).to_time,
          Date.new(2014, 7, 23).to_time,
          Date.new(2014, 7, 24).to_time,
          Date.new(2014, 7, 25).to_time,
          Date.new(2014, 7, 26).to_time,
          Date.new(2014, 7, 27).to_time
        ]
      end

      it 'should return nil if the given date is before the first date' do
        expect(api.send(:determine_date, date_array, Time.new(2014, 7, 20, 3, 56, 24))).to be_nil
      end


      it 'should return 2014-07-21 if the date is sometime on the 21st' do
        expect(api.send(:determine_date, date_array, Time.new(2014, 7, 21, 3, 56, 24))).to eq Date.new(2014, 7, 21).to_time
      end


      it 'should return 2014-7-25 if the date is sometime on 25th' do
        expect(api.send(:determine_date, date_array, Time.new(2014, 7, 25, 3, 56, 24))).to eq Date.new(2014, 7, 25).to_time
      end

      it 'should return 2014-7-27 if the date is sometime on 27th' do
        expect(api.send(:determine_date, date_array, Time.new(2014, 7, 25, 3, 56, 24))).to eq Date.new(2014, 7, 25).to_time
      end

      it 'should raise if the date is more than 24 hours after the last date' do
        expect {
          api.send(:determine_date, date_array, Time.new(2014, 7, 29, 3, 56, 24))
          }.to raise_error RuntimeError, 'Given time of 2014-07-29 03:56:24 is more than 24 hours after last date in period (2014-07-27 00:00:00)'
      end

      it 'should raise if the date is 24 hours and 1 second after the last date in the array' do
        expect {
          api.send(:determine_date, date_array, Time.new(2014, 7, 28, 0, 0, 1))
          }.to raise_error RuntimeError, 'Given time of 2014-07-28 00:00:01 is more than 24 hours after last date in period (2014-07-27 00:00:00)'
      end

      it 'should return the last day if the time 1 second before 24  hours after the last date in the array' do
        expect(api.send(:determine_date, date_array, Time.new(2014, 7, 27, 23, 59, 59))).to eq Date.new(2014, 7, 27).to_time
      end
    end



    describe '#analyse_hash' do

      let(:today)   { Date.today }

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
        expect(api.send(:analyse_hash, hash)).to eq expected_result
      end

      it 'should cope with days when there arent any errors' do
        error_times = [
            make_date_time(1, 3, 56, 45),
            make_date_time(1, 5, 45, 3),
            make_date_time(1, 15, 45, 3),
            make_date_time(1, 16, 45, 3),
            make_date_time(4, 5, 45, 3),
            make_date_time(4, 5, 45, 3),
            make_date_time(4, 5, 45, 3),
            make_date_time(5, 5, 45, 3),
            make_date_time(8, 5, 45, 3),
            make_date_time(8, 5, 45, 3),
            make_date_time(8, 5, 45, 3)
          ]
        hash = make_hash_from_error_times(error_times)
        expected_result = construct_result(7, 8, [0, 1, 3, 0, 0, 4, 0])
        expect(api.send(:analyse_hash, hash)).to eq expected_result
      end
    end                       # describe '#analyse_hash'
  end                         # context private mehods
end                           # describe AppSignalApi

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

