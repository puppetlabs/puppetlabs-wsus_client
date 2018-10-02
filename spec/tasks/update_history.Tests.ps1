$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
$helper = Join-Path (Split-Path -Parent $here) 'spec_helper.ps1'
. $helper
$sut = Join-Path -Path $src -ChildPath "tasks/${sut}"

. $sut -NoOperation

Describe 'Convert-ToServerSelectionString' {
  It 'should enumerate default server' {
    Convert-ToServerSelectionString 0 | Should Be 'Default'
  }

  It 'should enumerate managed server' {
    Convert-ToServerSelectionString 1 | Should Be 'ManagedServer'
  }

  It 'should enumerate a Windows Update server' {
    Convert-ToServerSelectionString 2 | Should Be 'WindowsUpdate'
  }

  It 'should enumerate an other server' {
    Convert-ToServerSelectionString 3 | Should Be 'Other'
  }
}

Describe 'Convert-ToOperationResultCodeString' {
  It 'should enumerate not started operation' {
    Convert-ToOperationResultCodeString 0 | Should Be 'Not Started'
  }

  It 'should enumerate in progress operation' {
    Convert-ToOperationResultCodeString 1 | Should Be 'In Progress'
  }

  It 'should enumerate a succesful operation' {
    Convert-ToOperationResultCodeString 2 | Should Be 'Succeeded'
  }

  It 'should enumerate a succesful with errors operation' {
    Convert-ToOperationResultCodeString 3 | Should Be 'Succeeded With Errors'
  }

  It 'should enumerate a failed operation' {
    Convert-ToOperationResultCodeString 4 | Should Be 'Failed'
  }

  It 'should enumerate an abort operation' {
    Convert-ToOperationResultCodeString 5 | Should Be 'Aborted'
  }
}

Describe 'Convert-ToUpdateOperationString' {
  It 'should enumerate installation operations' {
    Convert-ToUpdateOperationString 1 | Should Be 'Installation'
  }

  It 'should enumerate uninstallation operations' {
    Convert-ToUpdateOperationString 2 | Should Be 'Uninstallation'
  }
}

Describe 'Invoke-ExecuteTask' {
  $DefaultExecuteParams = @{
    Detailed = $false;
    Title = $null
    UpdateID = $null
    MaximumUpdates = 300
  }

  It 'should return empty JSON if no history' {
    Mock Get-UpdateSessionObject { New-MockUpdateSession 0 }

    $Result = Invoke-ExecuteTask @DefaultExecuteParams | ConvertFrom-JSON
    $Result | Should -HaveCount 0
  }

  It 'should return a JSON array for a single element' {
    Mock Get-UpdateSessionObject { New-MockUpdateSession 1 }

    $ResultJSON = Invoke-ExecuteTask @DefaultExecuteParams
    $ResultJSON | Should -Match "^\["
    $ResultJSON | Should -Match "\]$"

    $Result = $ResultJSON | ConvertFrom-JSON
    $Result | Should -HaveCount 1
  }

  It 'should not return detailed information when Detailed specified as false' {
    Mock Get-UpdateSessionObject { New-MockUpdateSession 1 }
    $ExecuteParams = $DefaultExecuteParams.Clone()
    $ExecuteParams.Detailed = $false

    $Result = Invoke-ExecuteTask @ExecuteParams | ConvertFrom-JSON
    $Result | Should -HaveCount 1
    $Result[0].HResult | Should -BeNullOrEmpty
    $Result[0].Description | Should -BeNullOrEmpty
    $Result[0].UnmappedResultCode | Should -BeNullOrEmpty
    $Result[0].ClientApplicationID | Should -BeNullOrEmpty
    $Result[0].ServerSelection | Should -BeNullOrEmpty
    $Result[0].UninstallationSteps | Should -BeNullOrEmpty
    $Result[0].UninstallationNotes | Should -BeNullOrEmpty
    $Result[0].SupportUrl | Should -BeNullOrEmpty
    $Result[0].UnmappedResultCode | Should -BeNullOrEmpty
    $Result[0].UnmappedResultCode | Should -BeNullOrEmpty
  }

  It 'should return detailed information when Detailed specified as true' {
    Mock Get-UpdateSessionObject { New-MockUpdateSession 1 }
    $ExecuteParams = $DefaultExecuteParams.Clone()
    $ExecuteParams.Detailed = $true

    $Result = Invoke-ExecuteTask @ExecuteParams | ConvertFrom-JSON
    $Result | Should -HaveCount 1
    $Result[0].HResult | Should -Not -BeNullOrEmpty
    $Result[0].Description | Should -Not -BeNullOrEmpty
    $Result[0].UnmappedResultCode | Should -Not -BeNullOrEmpty
    $Result[0].ClientApplicationID | Should -Not -BeNullOrEmpty
    $Result[0].ServerSelection | Should -Not -BeNullOrEmpty
    $Result[0].UninstallationSteps | Should -Not -BeNullOrEmpty
    $Result[0].UninstallationNotes | Should -Not -BeNullOrEmpty
    $Result[0].SupportUrl | Should -Not -BeNullOrEmpty
    $Result[0].UnmappedResultCode | Should -Not -BeNullOrEmpty
    $Result[0].UnmappedResultCode | Should -Not -BeNullOrEmpty
  }

  It 'should return only the maximum number of updates when specified' {
    Mock Get-UpdateSessionObject { New-MockUpdateSession 20 }
    $ExecuteParams = $DefaultExecuteParams
    $ExecuteParams.MaximumUpdates = 5

    $Result = Invoke-ExecuteTask @ExecuteParams | ConvertFrom-JSON
    $Result | Should -HaveCount 5
  }

  It 'should return a single update when UpdateID is specified' {
    $UpdateGUID = [GUID]::NewGuid().ToString()
    $UpdateObject = New-MockUpdate -UpdateID $UpdateGUID
    Mock Get-UpdateSessionObject { New-MockUpdateSession 10 @($UpdateObject) }
    $ExecuteParams = $DefaultExecuteParams.Clone()
    $ExecuteParams.UpdateID = $UpdateGUID

    $Result = Invoke-ExecuteTask @ExecuteParams | ConvertFrom-JSON
    $Result | Should -HaveCount 1
  }

  It 'should return a matching updates when Title is specified' {
    $UpdateObjects = @(
      New-MockUpdate -Title 'asserttitle'
      New-MockUpdate -Title 'zzAssertTitlezz'
    )
    Mock Get-UpdateSessionObject { New-MockUpdateSession 10 $UpdateObjects }
    $ExecuteParams = $DefaultExecuteParams.Clone()
    $ExecuteParams.Title = 'AssertTitle'

    $Result = Invoke-ExecuteTask @ExecuteParams | ConvertFrom-JSON
    $Result | Should -HaveCount 2

    $UpdateTitles = $Result | ForEach-Object { Write-Output $_.Title }
    $UpdateTitles | Should -Contain 'asserttitle'
    $UpdateTitles | Should -Contain 'zzAssertTitlezz'
  }
}
