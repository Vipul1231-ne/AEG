<# 
Configures Windows Firewall for a LAN honeypot run.

Run this from an Administrator PowerShell window:
  powershell -ExecutionPolicy Bypass -File .\scripts\windows_lan_firewall.ps1

What it does:
  - Allows inbound LAN access to AegisTrap trap ports: 2222, 2121, 8080, 8443.
  - Blocks inbound access to the dashboard port: 5000.
  - Blocks common real-service footprint ports seen in LAN scans
    such as XAMPP, SMB/RPC, VMware, MySQL, and Windows dynamic RPC.
  - Leaves Windows' default inbound policy as "Block" for Private/Public profiles.

This script cannot hide ports already allowed by other firewall rules.
Review Windows Defender Firewall if other services are still visible.
#>

[CmdletBinding()]
param(
    [int[]]$TrapPorts = @(2222, 2121, 8080, 8443),
    [int]$DashboardPort = 5000,
    [int[]]$RealServicePorts = @(
        80, 135, 139, 443, 445,
        902, 912,
        3306, 3307, 5040,
        22644, 31939, 33060, 33696, 44573,
        49664, 49665, 49666, 49667, 49668,
        49698, 49699, 49700, 49704, 49705,
        49706, 49707, 49708, 49709, 49710
    ),
    [string]$GroupName = "AegisTrap LAN Honeypot"
)

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $isAdmin) {
    Write-Error "Open PowerShell as Administrator, then run this script again."
    exit 1
}

Write-Host "Configuring Windows Firewall for AegisTrap..."

Get-NetFirewallRule -Group $GroupName -ErrorAction SilentlyContinue | Remove-NetFirewallRule

Set-NetFirewallProfile -Profile Private,Public -DefaultInboundAction Block

New-NetFirewallRule `
    -DisplayName "AegisTrap block real service footprint ports" `
    -Group $GroupName `
    -Direction Inbound `
    -Action Block `
    -Protocol TCP `
    -LocalPort $RealServicePorts `
    -Profile Any `
    -Description "Hide real Windows/app services from LAN scans while the honeypot is running."

New-NetFirewallRule `
    -DisplayName "AegisTrap block Windows dynamic RPC range" `
    -Group $GroupName `
    -Direction Inbound `
    -Action Block `
    -Protocol TCP `
    -LocalPort 49152-65535 `
    -Profile Any `
    -Description "Hide Windows dynamic RPC/service ports from LAN scans."

New-NetFirewallRule `
    -DisplayName "AegisTrap allow LAN trap ports" `
    -Group $GroupName `
    -Direction Inbound `
    -Action Allow `
    -Protocol TCP `
    -LocalPort $TrapPorts `
    -Profile Private `
    -Description "Expose only AegisTrap honeypot services on the LAN."

New-NetFirewallRule `
    -DisplayName "AegisTrap block dashboard from LAN" `
    -Group $GroupName `
    -Direction Inbound `
    -Action Block `
    -Protocol TCP `
    -LocalPort $DashboardPort `
    -Profile Any `
    -Description "Keep the AegisTrap dashboard local-only."

Write-Host ""
Write-Host "Done. LAN clients should use only these trap ports:"
$TrapPorts | ForEach-Object { Write-Host "  TCP $_" }
Write-Host ""
Write-Host "Dashboard remains local on http://127.0.0.1:$DashboardPort"
Write-Host ""
Write-Host "Blocked real-service footprint ports:"
$RealServicePorts | Sort-Object -Unique | ForEach-Object { Write-Host "  TCP $_" }
Write-Host "  TCP 49152-65535"
Write-Host ""
Write-Host "Warning: this can break LAN access to file sharing, XAMPP, VMware, MySQL, and other local services."
Write-Host "If other ports are still visible, identify them with .\scripts\windows_list_listening_ports.ps1 and add them to RealServicePorts."
