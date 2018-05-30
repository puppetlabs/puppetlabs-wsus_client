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

$Session = New-Object -ComObject "Microsoft.Update.Session"
$Searcher = $Session.CreateUpdateSearcher()
# Returns IUpdateSearcher https://msdn.microsoft.com/en-us/library/windows/desktop/aa386515(v=vs.85).aspx

$historyCount = $Searcher.GetTotalHistoryCount()
$Searcher.QueryHistory(0, $historyCount) | ForEach-Object -Process {
  # Returns IUpdateHistoryEntry https://msdn.microsoft.com/en-us/library/windows/desktop/aa386400(v=vs.85).aspx
  $props = @{
    'Operation' = Convert-ToUpdateOperationString $_.Operation
    'ResultCode' = Convert-ToOperationResultCodeString $_.ResultCode
    'HResult' = $_.HResult
    'Date' = Get-SafeDateTime $_.Date
    'UpdateIdentity' = @{}
    'Title' = Get-SafeString $_.Title
    'Description' = Get-SafeString $_.Description
    'UnmappedResultCode' = $_.UnmappedResultCode
    'ClientApplicationID' = Get-SafeString $_.ClientApplicationID
    'ServerSelection' = Convert-ToServerSelectionString $_.ServerSelection
    'ServiceID' = Get-SafeString  $_.ServiceID
    'UninstallationSteps' = @()
    'UninstallationNotes' = Get-SafeString $_.UninstallationNotes
    'SupportUrl' = Get-SafeString $_.SupportUrl
    'Categories' = @()
  }

  $_.Categories | % { $props.Categories += $_.Name } | Out-Null
  $props['UpdateIdentity']['RevisionNumber'] = $_.UpdateIdentity.RevisionNumber
  $props['UpdateIdentity']['UpdateID'] = $_.UpdateIdentity.UpdateID
  $_.UninstallationSteps | % { $props.UninstallationSteps += $_ } | Out-Null

  New-Object -TypeName PSObject -Property $props
} | ConvertTo-JSON
