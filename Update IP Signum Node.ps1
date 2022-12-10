#Variables
$CurrentIP = (Invoke-WebRequest -uri "http://ifconfig.me/ip" -UseBasicParsing -TimeoutSec 20).Content
$fileTXTLog = "<<Here put the log path you want>>\Log IP Signum Node.txt"
$tempfileTXTLog = "<<Here put the log path you want>>\temp Log IP Signum Node.txt"
$nodeConfigFile = "<<Here put the path of the folder where the Signum Node is located>>\conf\node.properties"

# Function that creates a log file if none is found, otherwise it gets updated, note that the most recent row will be on top, to improve readability.
Function Update-Log {
    # Puts the new row in top of the old ones.
    $CurrentLog = Get-Content -Path $fileTXTLog -Force
    Start-Sleep -Milliseconds 1000
    $NewRow = Get-Content -Path $tempfileTXTLog -Force
    Start-Sleep -Milliseconds 1000
    $NewRow | Out-File -FilePath $fileTXTLog -Force
    Start-Sleep -Milliseconds 1000
    $CurrentLog | Out-File -FilePath $fileTXTLog -Append -Force
    Start-Sleep -Milliseconds 1000
    # Deletes the temporary file.
    Remove-item -Path $tempfileTXTLog -Force
}

# If it's impossible to retrieve the current public IP, log file is updated with a new row.
If ($null -eq $CurrentIP) {
    $DateTimeUpdate = Get-Date -Format "dddd dd MMMM yyyy HH:mm:ss"
    "$DateTimeUpdate -> Unable to retrieve public IP." | Out-File -FilePath $tempfileTXTLog -Force -Append
    Update-Log
}
# If the current public IP is retrieved successfully, the old IP is readden from the conf file.
Else {
    $line = Get-Content $nodeConfigFile | Select-String -Pattern "P2P.myAddress = " | Select-Object -ExpandProperty Line
    $lineToClean = Get-Content $nodeConfigFile | Select-String -Pattern "P2P.myAddress = " | Select-Object -ExpandProperty Line
    $lineOnlyIP = $lineToClean.Replace("P2P.myAddress = ", "")
    $content = Get-Content -Path $nodeConfigFile
    
    # If the 2 IP addresses coincide nothing happens.
    If ($line -eq "P2P.myAddress = $CurrentIP") {
    }
    # If the 2 IPs do not coincide, Signum Node conf file is updatedwith the new IP, Signum Node is restarted and log file is updated with a new row.
    elseif ($line -ne "P2P.myAddress = $CurrentIP") {
        $content | ForEach-Object { $_ -replace $line, "P2P.myAddress = $CurrentIP" } | Set-Content -Path $nodeConfigFile
        Stop-Process -Name javaw -Force
        Start-Sleep -Milliseconds 2000
        Start-Process -FilePath "<<Here put the path of the folder where the Signum Node is located>>\signum-node.exe"
        # This line is for BGInfo in case you want it to stay updated when the public IP changes.
        # Start-Process -FilePath "<<Path of BGInfo installation.>>\Bginfo64.exe" "<<Path of the BGInfo config file.>>\LegoLab.bgi /timer:0"
        $DateTimeUpdate = Get-Date -Format "dddd dd MMMM yyyy HH:mm:ss"
        "$DateTimeUpdate -> Old IP $lineOnlyIP -> Old IP $CurrentIP" | Out-File -FilePath $tempfileTXTLog -Force -Append
        Update-Log
    }
}
