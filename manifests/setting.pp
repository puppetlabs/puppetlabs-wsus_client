##
#
##
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
