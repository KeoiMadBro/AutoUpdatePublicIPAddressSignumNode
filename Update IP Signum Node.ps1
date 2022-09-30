$CurrentIP = (Invoke-WebRequest -uri "http://ifconfig.me/ip" -UseBasicParsing).Content

$OldIP = Get-Content "<<Here put the path of the folder where the Signum Node is located>>\conf\node-default.properties" | Select-String -Pattern "P2P.myAddress = " | Select-Object -ExpandProperty Line

$content = Get-Content "<<Here put the path of the folder where the Signum Node is located>>\conf\node-default.properties"

# If the IP inside the config file is the same as the new one, nothing is gonna happen.
If ( $OldIP -eq "P2P.myAddress = $CurrentIP" ) {
}
# If it's not, the current IP is replaced with the new one, then the Signum Node is stopped, and after 10 seconds is started.
elseif ( $OldIP -ne "P2P.myAddress = $CurrentIP" ) {
    $content | ForEach-Object { $_ -replace $OldIP, "P2P.myAddress = $CurrentIP" } | Set-Content "<<Here put the path of the folder where the Signum Node is located>>\conf\node-default.properties"
    Stop-Process -Name javaw -Force
    Start-Sleep -Milliseconds 10000
    Start-Process -FilePath "<<Here put the path of the folder where the Signum Node is located>>\signum-node.exe"
    
    # The next 2 rows will create a .txt file which acts as a log file with date and time, old IP address and new IP address.
    $DateTimeUpdate = Get-Date -Format "dddd dd/MMM/yyyy HH:mm:ss"
    "$DateTimeUpdate / Old myAddress string -> $OldIP / New IP -> $CurrentIP" | Out-File -FilePath "C:\Users\$ENV:USERNAME\Desktop\IP changed.txt" -Force -Append
}
