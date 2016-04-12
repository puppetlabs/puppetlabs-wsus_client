require 'spec_helper'

describe 'parse_auto_update_option' do
  expected_hash = {'NotifyOnly' => 2,
                   'AutoNotify' => 3,
                   'Scheduled' => 4,
                   'AutoInstall' => 5, }

  expected_hash.keys.each do |auto_update_option|
    describe "when parsing #{auto_update_option}" do
      it {
        expect(scope.function_parse_auto_update_option([auto_update_option])).to eq(expected_hash[auto_update_option])
      }
    end

    describe "when parsing #{auto_update_option.upcase}" do
      it {
        expect(scope.function_parse_auto_update_option([auto_update_option.upcase])).to eq(expected_hash[auto_update_option])
      }
    end

    describe "when parsing #{auto_update_option.downcase}" do
      it {
        expect(scope.function_parse_auto_update_option([auto_update_option.downcase])).to eq(expected_hash[auto_update_option])
      }
    end
  end

  expected_hash.values.each do |auto_update_value|
    describe "when parsing #{auto_update_value}" do
      it {
        expect(scope.function_parse_auto_update_option([auto_update_value])).to eq(auto_update_value)
      }
    end
  end

  describe "when passing 'Whatthe'" do
    it 'should raise error' do
      expect {
        scope.function_parse_auto_update_option(['Whatthe'])
      }.to raise_error(Puppet::Error,
                       "Valid options for auto_update_option are #{expected_hash.keys.join('|')}|2|3|4|5, provided 'Whatthe'")
    end
  end
end
