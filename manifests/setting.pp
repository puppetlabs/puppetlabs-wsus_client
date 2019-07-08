# @summary
#   Manages wsus_client settings
#
# @param ensure
#   Specifies whether the setting should exist. Valid options: 'present', 'absent', and 'file'
#
# @param key
#   Specifies registry_value
#
# @param data
#   Incoming data
#
# @param type
#    Data type. default value: dword
#
# @param has_enabled
#   Specifies whether the key should be enabled. Boolean value
#
# @param validate_range
#   Specifies whether the data should be validated as a number in a certain range
#
# @param validate_bool
#   Specifies whether the data should be validated as a boolean value
#
define wsus_client::setting(
  $ensure = 'present',
  $key = $title,
  $data = undef,
  $type = 'dword',
  $has_enabled = true,
  $validate_range = undef,
  $validate_bool = false,

)
{
  assert_private()
  if $data != undef {
    if $has_enabled {
      registry_value{ "${key}Enabled":
        type => dword,
        data => bool2num($data != false)
      }
    }
    if ($data and $data != true) or $validate_bool{
      if $validate_range {
        validate_in_range($data,$validate_range[0],$validate_range[1])
      }
      if $validate_bool {
        validate_bool($data)
      }
      $_data = $validate_bool ? {
        true => bool2num($data),
        false => $data
      }
      registry_value{ $key:
        ensure => $ensure,
        type   => $type,
        data   => $_data,
      }
    }
  }
}
