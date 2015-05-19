require 'beaker-rspec'

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
end

FUTURE_PARSER = ENV['FUTURE_PARSER'] == 'true' || false

unless ENV['RS_PROVISION'] == 'no' or ENV['BEAKER_provision'] == 'no'
  is_foss = (ENV['IS_PE'] == 'no' || ENV['IS_PE'] == 'false') ? true : false
  if hosts.first.is_pe? && !is_foss
    install_pe
  else
    version = ENV['PUPPET_VERSION'] || '3.7.4'
    download_url = ENV['WIN_DOWNLOAD_URL'] || 'http://downloads.puppetlabs.com/windows/'
    hosts.each do |host|
      if host['platform'] =~ /windows/i
        install_puppet_from_msi(host,
                                {
                                  :win_download_url => download_url,
                                  :version => version,
                                  :install_32 => true})
      end
    end
  end

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

