# frozen_string_literal: true

#
#  To write custom funtion, we use the legacy Ruby functions API, which uses the Puppet::Parser::Functions namespace.
#  Custom function: validate_in_range
#
module Puppet::Parser::Functions
  newfunction(:validate_in_range, doc: <<-DOCUMENTATION
    @summary
      Validate the incoming value is in a certain range.

    @return
      Raises an error if the given value fails this validation.

  DOCUMENTATION
  ) do |args|
    data, min, max = *args

    data = Integer(data)
    min = Integer(min)
    max = Integer(max)
    raise("Expected #{data} to be greater or equal to #{min}, got #{data}") if data < min
    raise("Expected #{data} to be less or equal to #{min}, got #{data}") if data > max
  end
end
