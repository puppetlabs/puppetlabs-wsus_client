$DebugPreference = "SilentlyContinue"

$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$src = Resolve-Path -Path "$($here)\.."
Function New-MockUpdate($UpdateID, $Title) {
  $properties = @{
    Operation = Get-Random -Minimum 1 -Maximum 3
    ResultCode = Get-Random -Minimum 0 -Maximum 6
    Date = [DateTime]::Now
    UpdateIdentity = @{
      RevisionNumber = Get-Random -Minimum 1 -Maximum 11
      UpdateID = [GUID]::NewGuid().ToString()
    }
    Title = "Mock Update Title $(Get-Random)"
    ServiceID = [GUID]::NewGuid().ToString()
    Categories = @() # TODO
    HResult = Get-Random -Minimum 0 -Maximum 32768
    Description = "Mock Description $(Get-Random)"
    UnmappedResultCode = Get-Random -Minimum 0 -Maximum 32768

    ClientApplicationID = "Mock ClientApplicationID $(Get-Random)"
    ServerSelection = Get-Random -Minimum 0 -Maximum 4
    UninstallationSteps = @("Mock UninstallationStep $(Get-Random)")
    UninstallationNotes = "Mock UninstallationNotes $(Get-Random)"
    SupportUrl = "Mock SupportUrl $(Get-Random)"
  }

  if (-Not [String]::IsNullOrEmpty($UpdateID)) { $properties.UpdateIdentity.UpdateID = $UpdateID}
  if (-Not [String]::IsNullOrEmpty($Title)) { $properties.Title = $Title}

  New-Object -TypeName PSObject -Property $properties
}
Function New-MockUpdateSession($UpdateCount = 0, $UpdateObjects = @()) {
  $mock = New-Object -TypeName PSObject

  $mock | Add-Member -MemberType NoteProperty -Name MockGetTotalHistoryCount -Value $UpdateCount | Out-Null

  # Create a random update list
  $Updates = $UpdateObjects
  While ($Updates.Count -lt $UpdateCount) {
    $Updates += New-MockUpdate
  }
  $mock | Add-Member -MemberType NoteProperty -Name MockQueryHistory -Value $Updates | Out-Null

  # The following are methods not a properties and we can't do closures so just mirror the mock properties
  $mock | Add-Member -MemberType ScriptMethod -Name GetTotalHistoryCount -Value { $this.MockGetTotalHistoryCount } | Out-Null
  $mock | Add-Member -MemberType ScriptMethod -Name QueryHistory -Value { param($start, $count) $this.MockQueryHistory[$start..($start + $count - 1)] } | Out-Null

  Write-Output $mock
}
