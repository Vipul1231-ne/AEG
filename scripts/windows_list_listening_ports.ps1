<#
Shows which local processes are listening on TCP ports.

Run in PowerShell:
  powershell -ExecutionPolicy Bypass -File .\scripts\windows_list_listening_ports.ps1
#>

$rows = foreach ($connection in (Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Sort-Object LocalPort, LocalAddress)) {
    $process = Get-Process -Id $connection.OwningProcess -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        Address = $connection.LocalAddress
        Port = $connection.LocalPort
        ProcessId = $connection.OwningProcess
        Process = if ($process) { $process.ProcessName } else { "unknown" }
    }
}

$rows | Format-Table -AutoSize
