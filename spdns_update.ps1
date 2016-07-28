Clear-Host

# adjust your values
$fqdn = ""
$pwd = ""
$user = ""

# (optional) set full path to (writable) logfile and switch logging on ($true) or off ($false)
$myLogFile = "C:\scripts\spdns_update.log"
$logging = $false

# no necessity to edit below this line
$registeredIP = ""
$currentIP = ""

$myServiceList = "http://api.ipify.org","http://ipecho.net/plain","http://checkip4.spdns.de"

function log {
    param(
        [Parameter(ValueFromPipeline=$true)]
        $piped
    )

    if ($logging) {
        (Get-Date -Format yyyyMMddHHmmss).ToString() + " " + `
            $piped | Out-File -FilePath $myLogFile -Append
        }
    # console output
    "$piped"
}


function checkIP ($myServiceAddress) {

    try {
        $myIP = Invoke-WebRequest -Uri $myServiceAddress -UseBasicParsing
    } catch {
        "checkIP " + $_.Exception.Message | log
        exit 1
    }
    Return "$myIP"
}

$currentIP = checkIP (Get-Random -InputObject $myServiceList)

try {
    $registeredIP = (Resolve-DnsName $fqdn).IPAddress
} catch {
    "Resolve DNS Name " + $_.Exception.Message | log
    exit 1
}

if ($registeredIP -like $currentIP) {
    "Precheck " + "IP $currentIP already registered." | log
    exit 0
} else {
    $secpasswd = ConvertTo-SecureString $pwd -AsPlainText -Force
    $myCreds = New-Object System.Management.Automation.PSCredential ($user, $secpasswd)
    $url = "https://update.spdyn.de/nic/update?hostname=$fqdn&myip=$currentIP"

    try {
        $resp = Invoke-WebRequest -Uri $url -Credential $myCreds -UseBasicParsing
    } catch {
        "Update DNS " + $_.Exception.Message | log
        exit 1
    }

    "SPDNS result " + $resp.Content | log

}

exit 0
