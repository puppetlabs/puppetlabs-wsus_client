require 'beaker-rspec'
require 'beaker/puppet_install_helper'

run_puppet_install_helper
install_ca_certs_on default

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
end

unless ENV['MODULE_provision'] == 'no'
  puts "Install wsus_client module to agent #{default.node_name}"
  result = on default, "echo #{default['distmoduledir']}"
  target = result.raw_output.chomp
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  on default, puppet("module install puppetlabs-stdlib")
  on default, puppet("module install puppetlabs-registry")
  install_dev_puppet_module_on(default, {:proj_root => proj_root, :target_module_path => "#{target}", :module_name => 'wsus_client'})
end

