# frozen_string_literal: true

#
#  To write custom funtion, we use the legacy Ruby functions API, which uses the Puppet::Parser::Functions namespace.
#  Custom function: parse_auto_update_option
#
module Puppet::Parser::Functions
  newfunction(:parse_auto_update_option, type: :rvalue, arity: 1, doc: <<-DOCUMENTATION
    @summary
      Parse the incoming value to the corresponding integer, if integer is supplied simply return value

    @return [Integer] option auto_update_option as an integer

    > *Note:*
    Valid options for auto_update_option are NotifyOnly|AutoNotify|Scheduled|AutoInstall|2|3|4|5
  DOCUMENTATION
  ) do |args|
    autoupdate_hash = { 'notifyonly' => 2,
                        'autonotify' => 3,
                        'scheduled' => 4,
                        'autoinstall' => 5 }

    option = args[0]
    error_msg = "Valid options for auto_update_option are NotifyOnly|AutoNotify|Scheduled|AutoInstall|2|3|4|5, provided '#{option}'"
    if option.is_a?(Numeric) || option =~ %r{^\d$}
      option = Integer(option) if option.is_a?(String)
      raise Puppet::ParseError, error_msg if option < 2 || option > 5

      return option
    end

    return autoupdate_hash[option.downcase] if autoupdate_hash.key?(option.downcase)

    raise Puppet::ParseError, error_msg
  end
end
