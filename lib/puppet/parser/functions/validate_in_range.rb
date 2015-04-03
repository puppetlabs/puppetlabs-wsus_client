module Puppet::Parser::Functions

  newfunction(:validate_in_range) do |args|

    data, min, max = *args

    data = Integer(data)
    min = Integer(min)
    max = Integer(max)
    if (data < min)
      fail("Expected #{data} to be greater or equal to #{min}, got #{data}")
    end
    if (data > max)
      fail("Expected #{data} to be less or equal to #{min}, got #{data}")
    end
  end
end
