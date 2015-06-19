require 'beaker-rspec'
require 'beaker/puppet_install_helper'

run_puppet_install_helper

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
end

unless ENV['MODULE_provision'] == 'no'
  puts "Install wsus_client module to agent #{default.node_name}"
  result = on default, "echo #{default['distmoduledir']}"
  target = result.raw_output.chomp
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  {'stdlib' => '4.6.0', 'registry' => '1.1.0'}.each do |repo, version|
    on default, "rm -rf #{target}/#{repo};git clone --branch #{version} --depth 1 https://github.com/puppetlabs/puppetlabs-#{repo} #{target}/#{repo}"
  end
  install_dev_puppet_module_on(default, {:proj_root => proj_root, :target_module_path => "#{target}", :module_name => 'wsus_client'})
end

