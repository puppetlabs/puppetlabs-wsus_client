require 'beaker-pe'
require 'beaker-puppet'
require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/testmode_switcher'
require 'beaker/testmode_switcher/dsl'

# Install Puppet Agent
run_puppet_install_helper
configure_type_defaults_on(hosts)

# Install Forge certs to allow for PMT installation.
install_ca_certs_on default

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
end

unless ENV['MODULE_provision'] == 'no'
  # Determine root path of local module source.
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # In CI install from staging forge, otherwise from local
  staging = { :module_name => 'puppetlabs-wsus_client' }
  local = { :module_name => 'wsus_client', :source => proj_root }

  # Install wsus_client module from the forge or from local source.
  if options[:forge_host]
    hosts.each do |host|
      install_dev_puppet_module_on(host, staging)
    end
  else
    hosts.each do |host|
      # Install wsus_client dependencies.
      %w(puppetlabs-stdlib puppetlabs-registry).each do |dep|
        on(host, puppet("module install #{dep}"))
      end

      install_dev_puppet_module_on(host, local)
    end
  end
end
