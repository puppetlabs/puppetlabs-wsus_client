if ($ENV:APPVEYOR -eq 'True') {
  Write-Host "Installing Pester ..."
  & choco install pester --version 4.10.1
}

Import-Module Pester

Write-Host "Running Pester ..."

Invoke-Pester @args spec/tasks
