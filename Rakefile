require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet_blacksmith/rake_tasks' if Bundler.rubygems.find_name('puppet-blacksmith').any?

PuppetLint.configuration.send('disable_relative')

desc "Run PowerShell unit tests"
task :spec_pester do
  exec ("powershell -NoProfile -NoLogo -NonInteractive -Command \". spec/run_pester.ps1 -EnableExit \"")
end
