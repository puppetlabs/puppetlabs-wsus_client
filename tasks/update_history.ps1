[CmdletBinding()]
Param(
  [Parameter(Mandatory = $False)]
  [Switch]$Detailed,

  [Parameter(Mandatory = $False)]
  [String]$Title,

  [Parameter(Mandatory = $False)]
  [String]$UpdateID,

  [Parameter(Mandatory = $False)]
  [Int]$MaximumUpdates = 300,

  [Parameter(Mandatory = $False)]
  [Switch]$NoOperation
)

Function Get-SafeString($value) {
  if ($value -eq $null) {
    Write-Output ''
  } else {
    Write-Output $value.ToString()
  }
}

Function Get-SafeDateTime($value) {
  if ($value -eq $null) {
    Write-Output ''
  } else {
    Write-Output $value.ToString('u')
  }
}

Function Convert-ToServerSelectionString($value) {
  # https://msdn.microsoft.com/en-us/library/windows/desktop/aa387280(v=vs.85).aspx
  switch ($value) {
    0 { Write-Output 'Default' }
    1 { Write-Output 'ManagedServer' }
    2 { Write-Output 'WindowsUpdate' }
    3 { Write-Output 'Other' }
    Default { Write-Output "Unknown ${value}"}
  }
}

Function Convert-ToOperationResultCodeString($value) {
  # https://msdn.microsoft.com/en-us/library/windows/desktop/aa387095(v=vs.85).aspx
  switch ($value) {
    0 { Write-Output 'Not Started' }
    1 { Write-Output 'In Progress' }
    2 { Write-Output 'Succeeded' }
    3 { Write-Output 'Succeeded With Errors' }
    4 { Write-Output 'Failed' }
    5 { Write-Output 'Aborted' }
    Default { Write-Output "Unknown ${value}"}
  }
}

Function Convert-ToUpdateOperationString($value) {
  # https://msdn.microsoft.com/en-us/library/windows/desktop/aa387282(v=vs.85).aspx
  switch ($value) {
    1 { Write-Output 'Installation' }
    2 { Write-Output 'Uninstallation' }
    Default { Write-Output "Unknown ${value}"}
  }
}

Function Get-UpdateSessionObject() {
  $Session = New-Object -ComObject "Microsoft.Update.Session"
  Write-Output $Session.CreateUpdateSearcher()
}

Function Invoke-ExecuteTask($Detailed, $Title, $UpdateID, $MaximumUpdates) {
  $Searcher = Get-UpdateSessionObject
  # Returns IUpdateSearcher https://msdn.microsoft.com/en-us/library/windows/desktop/aa386515(v=vs.85).aspx

  $historyCount = $Searcher.GetTotalHistoryCount()
  if ($historyCount -gt $MaximumUpdates) { $historyCount = $MaximumUpdates }
  $Result = $Searcher.QueryHistory(0, $historyCount) |
    Where-Object { [String]::IsNullOrEmpty($Title) -or ($_.Title -match $Title) } |
    Where-Object { [String]::IsNullOrEmpty($UpdateID) -or ($_.UpdateIdentity.UpdateID -eq $UpdateID) } |
    ForEach-Object -Process {
    # Returns IUpdateHistoryEntry https://msdn.microsoft.com/en-us/library/windows/desktop/aa386400(v=vs.85).aspx

    # Basic Settings
    $props = @{
      'Operation' = Convert-ToUpdateOperationString $_.Operation
      'ResultCode' = Convert-ToOperationResultCodeString $_.ResultCode
      'Date' = Get-SafeDateTime $_.Date
      'UpdateIdentity' = @{}
      'Title' = Get-SafeString $_.Title
      'ServiceID' = Get-SafeString  $_.ServiceID
      'Categories' = @()
    }
    $_.Categories | % { $props.Categories += $_.Name } | Out-Null
    $props['UpdateIdentity']['RevisionNumber'] = $_.UpdateIdentity.RevisionNumber
    $props['UpdateIdentity']['UpdateID'] = $_.UpdateIdentity.UpdateID

    # Detailed Settings
    if ($Detailed) {
      $props['HResult'] = $_.HResult
      $props['Description'] = Get-SafeString $_.Description
      $props['UnmappedResultCode'] = $_.UnmappedResultCode
      $props['ClientApplicationID'] = Get-SafeString $_.ClientApplicationID
      $props['ServerSelection'] = Convert-ToServerSelectionString $_.ServerSelection
      $props['UninstallationSteps'] = @()
      $props['UninstallationNotes'] = Get-SafeString $_.UninstallationNotes
      $props['SupportUrl'] = Get-SafeString $_.SupportUrl
      $_.UninstallationSteps | % { $props.UninstallationSteps += $_ } | Out-Null
    }

    New-Object -TypeName PSObject -Property $props
  }

  if ($Result -ne $null) {
    if ($Result.GetType().ToString() -ne 'System.Object[]') {
      '[ ' + ($Result | ConvertTo-JSON) + ' ]'
    } else {
      $Result | ConvertTo-JSON
    }
  } else {
    '[ ]'
  }
}

if (-Not $NoOperation) { Invoke-ExecuteTask -Detailed $Detailed -Title $Title -UpdateID $UpdateID -MaximumUpdates $MaximumUpdates }
