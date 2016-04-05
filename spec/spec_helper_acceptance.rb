require 'beaker-rspec'
require 'beaker/puppet_install_helper'

# Install Puppet Agent
run_puppet_install_helper

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
    install_dev_puppet_module_on(default, staging)
  else
    # Install wsus_client dependencies.
    %w(puppetlabs-stdlib puppetlabs-registry).each do |dep|
      on(default, puppet("module install #{dep}"))
    end

    install_dev_puppet_module_on(default, local)
  end
end
