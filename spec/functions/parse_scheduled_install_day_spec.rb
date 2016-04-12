require 'spec_helper'

describe 'parse_scheduled_install_day' do
  expect_day = {'Everyday' => 0,
                'Sunday' => 1,
                'Monday' => 2,
                'Tuesday' => 3,
                'Wednesday' => 4,
                'Thursday' => 5,
                'Friday' => 6,
                'Saturday' => 7}

  expect_day.keys.each do |day|
    describe "when parsing #{day}" do
      it {
        expect(scope.function_parse_scheduled_install_day([day])).to eq(expect_day[day])
      }
    end

    dday = day.downcase
    describe "when parsing #{dday}" do
      it {
        expect(scope.function_parse_scheduled_install_day([dday])).to eq(expect_day[day])
      }
    end

    uday = day.upcase
    describe "when parsing #{uday}" do
      it {
        expect(scope.function_parse_scheduled_install_day([uday])).to eq(expect_day[day])
      }
    end
  end
  expect_day.values.each do |day|
    describe "when parsing #{day}" do
      it {
        expect(scope.function_parse_scheduled_install_day([day])).to eq(day)
      }
    end
  end
  describe "when passing 'Whatthe'" do
    it 'should raise error' do
      expect {
        scope.function_parse_scheduled_install_day(['Whatthe'])
      }.to raise_error(Puppet::Error,
                       "Valid options for scheduled_install_day are #{expect_day.keys.join('|')}|0-7, provided 'Whatthe'")
    end
  end
end
