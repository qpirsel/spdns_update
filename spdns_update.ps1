#requires -version 4

Clear-Host

# adjust your values
$fqdn = "dr-borho-ka.firewall-gateway.de"
$pwd = "mqox-groz-gaxc"
$user = "dr-borho-ka.firewall-gateway.de"
$dnsserver = "8.8.8.8"

# (optional) set full path to (writable) logfile and switch logging on ($true) or off ($false)
$myLogFile = "C:\Batches\SpDyn\spdns_update.log"
$logging = $true

# no necessity to edit below this line
$myServiceList = "http://ipecho.net/plain","http://checkip4.spdns.de"

function log {
    param(
        [Parameter(ValueFromPipeline=$true)]
        $piped
    )

    if ($logging) {
        (Get-Date -Format "yyyy-MM-dd HH:mm:ss").ToString() + " " + `
            $piped | Out-File -FilePath $myLogFile -Append
        }
    # console output
    "$piped"
}

function checkIP ($myServiceAddress) {

    try {
        $myIP = Invoke-WebRequest -Uri $myServiceAddress -UseBasicParsing -ErrorAction Stop
    } catch {
        "checkIP " + $_.Exception.Message | log
        exit 1
    }
    Return "$myIP"
}

$currentIP = checkIP (Get-Random -InputObject $myServiceList)



try {
if ($dnsserver -ne "") {
    $registeredIP = Resolve-DnsName $fqdn -Type A -ErrorAction Stop -Server $dnsserver }
    else{
    $registeredIP = Resolve-DnsName $fqdn -Type A -ErrorAction Stop}

} catch {
    "Resolve DNS Name " + $_.Exception.Message | log
    exit 1
}

if ($registeredIP[0].IPAddress -like $currentIP) {
    "Precheck " + "IP $currentIP already registered." | log
    exit 0
} else {
    $secpasswd = ConvertTo-SecureString $pwd -AsPlainText -Force
    $myCreds = New-Object System.Management.Automation.PSCredential ($user, $secpasswd)
    $url = "https://update.spdyn.de/nic/update?hostname=$fqdn&myip=$currentIP"

    try {
        $resp = Invoke-WebRequest -Uri $url -Credential $myCreds -UseBasicParsing -ErrorAction Stop
    } catch {
        "Update DNS " + $_.Exception.Message | log
        exit 1
    }

    "SPDNS result " + $resp.Content | log

}

exit 0
