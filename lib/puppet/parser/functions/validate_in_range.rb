# frozen_string_literal: true

#
#  To write custom funtion, we use the legacy Ruby functions API, which uses the Puppet::Parser::Functions namespace.
#  Custom function: validate_in_range
#
module Puppet::Parser::Functions
  newfunction(:validate_in_range, doc: <<-EOS
    @summary
      Validate the incoming value is in a certain range.

    @return
      Raises an error if the given value fails this validation.

  EOS
  ) do |args|
    data, min, max = *args

    data = Integer(data)
    min = Integer(min)
    max = Integer(max)
    if data < min
      raise("Expected #{data} to be greater or equal to #{min}, got #{data}")
    end
    if data > max
      raise("Expected #{data} to be less or equal to #{min}, got #{data}")
    end
  end
end
