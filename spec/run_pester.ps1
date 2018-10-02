if ($ENV:APPVEYOR -eq 'True') {
  Write-Host "Installing Pester ..."
  & cinst pester
}

Import-Module Pester

Write-Host "Running Pester ..."

Invoke-Pester @args spec/tasks
