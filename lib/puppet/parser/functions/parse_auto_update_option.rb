module Puppet::Parser::Functions
  newfunction(:parse_auto_update_option, :type => :rvalue, :arity => 1, :doc => <<-EOS
    Parse the incoming value to the corresponding integer, if integer is supplied simply return value
  EOS
  ) do |args|
    autoupdate_hash = {'notifyonly'  => 2,
                       'autonotify'  => 3,
                       'scheduled'   => 4,
                       'autoinstall' => 5}

    option = args[0]
    error_msg = "Valid options for auto_update_option are NotifyOnly|AutoNotify|Scheduled|AutoInstall|2|3|4|5, provided '#{option}'"
    if option.is_a?(Numeric) || option =~ /^\d$/
      if option.is_a?(String)
        option = Integer(option)
      end
      if option < 2 || option > 5
        raise Puppet::ParseError, error_msg
      end
      return option
    end

    if autoupdate_hash.has_key?(option.downcase)
      return autoupdate_hash[option.downcase]
    end
    raise Puppet::ParseError, error_msg
  end
end
