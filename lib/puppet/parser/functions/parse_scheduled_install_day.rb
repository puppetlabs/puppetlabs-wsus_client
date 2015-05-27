module Puppet::Parser::Functions
  newfunction(:parse_scheduled_install_day, :type => :rvalue, :arity => 1, :doc => <<-EOS
    Parse the incoming value to the corresponding integer, if integer is supplied simply return value
  EOS
  ) do |args|
    day_hash = {'Everyday' => 0,
                'Sunday' => 1,
                'Monday' => 2,
                'Tuesday' => 3,
                'Wednesday' => 4,
                'Thursday' => 5,
                'Friday' => 6,
                'Saturday' => 7}

    option = args[0]
    if option.is_a?(Numeric) || option =~ /^\d$/
      if option.is_a?(String)
        option = Integer(option)
      end
      if option < 0 || option > 7
        raise Puppet::ParseError, "Valid options for scheduled_install_day are #{day_hash.keys.join('|')}|0-7, provided '#{option}'"
      end
      return option
    end

    if day_hash.has_key?(option.capitalize)
      return day_hash[option.capitalize]
    end
    raise Puppet::ParseError, "Valid options for scheduled_install_day are #{day_hash.keys.join('|')}|0-7, provided '#{option}'"
  end
end
