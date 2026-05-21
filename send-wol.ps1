#!/usr/bin/env pwsh
# Send Wake-on-LAN Magic Packet
# Usage: .\send-wol.ps1 -MacAddress "C4:5A:B1:E7:5E:9A"
#        .\send-wol.ps1 -MacAddress "C4:5A:B1:E7:5E:9A","AA:BB:CC:DD:EE:FF"

param(
    [Parameter(Mandatory=$false)]
    [string[]]$MacAddress = @("00-24-27-15-6E-7C", "C4:5A:B1:E7:5E:9A"),
    
    [Parameter(Mandatory=$false)]
    [string]$BroadcastAddress = "255.255.255.255",
    
    [Parameter(Mandatory=$false)]
    [int]$Port = 9
)

function Send-WolPacket {
    param(
        [string]$Mac,
        [string]$Broadcast,
        [int]$UdpPort
    )
    
    # Remove colons/hyphens/periods from MAC address
    $cleanMac = $Mac -replace '[:\-.]',''

    # Validate MAC address
    if ($cleanMac.Length -ne 12 -or $cleanMac -notmatch '^[0-9A-Fa-f]+$') {
        Write-Host "✗ Invalid MAC address format: $Mac (use XX:XX:XX:XX:XX:XX, XX-XX-XX-XX-XX-XX, XX.XX.XX.XX.XX.XX, or XXXXXXXXXXXX)" -ForegroundColor Red
        return $false
    }

    # Convert MAC to byte array
    $macBytes = [byte[]]@()
    for ($i = 0; $i -lt 12; $i += 2) {
        $macBytes += [Convert]::ToByte($cleanMac.Substring($i, 2), 16)
    }

    # Build magic packet: 6 bytes of FF + 16 repetitions of MAC address
    $magicPacket = [byte[]](,0xFF * 6)
    for ($i = 0; $i -lt 16; $i++) {
        $magicPacket += $macBytes
    }

    # Send the packet
    try {
        $udpClient = New-Object System.Net.Sockets.UdpClient
        $udpClient.Connect([System.Net.IPAddress]::Parse($Broadcast), $UdpPort)
        [void]$udpClient.Send($magicPacket, $magicPacket.Length)
        $udpClient.Close()
        
        Write-Host "✓ Magic packet sent to $Mac" -ForegroundColor Green
        Write-Host "  Broadcast: $Broadcast`:$UdpPort" -ForegroundColor Cyan
        Write-Host "  Packet size: $($magicPacket.Length) bytes" -ForegroundColor Cyan
        return $true
    } catch {
        Write-Host "✗ Failed to send magic packet to $Mac`: $_" -ForegroundColor Red
        return $false
    }
}

# Process each MAC address
$successCount = 0
$totalCount = $MacAddress.Count

foreach ($mac in $MacAddress) {
    if (Send-WolPacket -Mac $mac -Broadcast $BroadcastAddress -UdpPort $Port) {
        $successCount++
    }
    
    # Add spacing between multiple sends
    if ($totalCount -gt 1) {
        Write-Host ""
    }
}

# Summary
if ($totalCount -gt 1) {
    Write-Host "Summary: $successCount/$totalCount packets sent successfully" -ForegroundColor $(if ($successCount -eq $totalCount) { "Green" } else { "Yellow" })
}

Write-Host "`nWait 10-30 seconds for the computer(s) to wake up..." -ForegroundColor Yellow
