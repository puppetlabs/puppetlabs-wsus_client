# frozen_string_literal: true

#
#  To write custom funtion, we use the legacy Ruby functions API, which uses the Puppet::Parser::Functions namespace.
#  Custom function: parse_scheduled_install_day
#
module Puppet::Parser::Functions
  newfunction(:parse_scheduled_install_day, type: :rvalue, arity: 1, doc: <<-DOCUMENTATION
    @summary
      Parse the incoming value to the corresponding integer, if integer is supplied simply return value

    @return [Integer] option scheduled_install_day as an integer

    > *Note:*
    Valid options for scheduled_install_day are Everyday|Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|0-7
  DOCUMENTATION
  ) do |args|
    day_hash = { 'Everyday' => 0,
                 'Sunday' => 1,
                 'Monday' => 2,
                 'Tuesday' => 3,
                 'Wednesday' => 4,
                 'Thursday' => 5,
                 'Friday' => 6,
                 'Saturday' => 7 }

    option = args[0]
    if option.is_a?(Numeric) || option =~ %r{^\d$}
      option = Integer(option) if option.is_a?(String)
      raise Puppet::ParseError, "Valid options for scheduled_install_day are #{day_hash.keys.join('|')}|0-7, provided '#{option}'" if option.negative? || option > 7

      return option
    end

    return day_hash[option.capitalize] if day_hash.key?(option.capitalize)

    raise Puppet::ParseError, "Valid options for scheduled_install_day are #{day_hash.keys.join('|')}|0-7, provided '#{option}'"
  end
end
