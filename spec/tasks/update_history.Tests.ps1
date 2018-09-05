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
