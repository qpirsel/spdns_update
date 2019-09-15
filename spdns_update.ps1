#requires -version 4

Clear-Host

# (mandatory) adjust your values
$fqdn = ""
$pwd = ""
$user = ""

# (optional) set full path to (writable) logfile and switch logging on ($true) or off ($false)
$myLogFile = "C:\scripts\spdns_update.log"
$logging = $false

# (optional) add or remove service sites. NOTE: A service sites MUST return a plain IP string WITHOUT any HTML tags!
$myServiceList = "http://ipecho.net/plain"`
                ,"http://checkip4.spdns.de"`
                ,"http://ident.me"`
                ,"http://plain-text-ip.com"

### no necessity to edit below this line ###
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
        $myIP = Invoke-WebRequest -Uri $myServiceAddress -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop

        if ( -not ($myIP) -or -not ($myIP -match '^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$')) {
            "checkIP " + "No valid response" | log
            exit 1
        }

    } catch {
        "checkIP " + $_.Exception.Message | log
        exit 1
    }

    Return "$myIP"
}

$usedService = Get-Random -InputObject $myServiceList
"checkIP " + "Determine current IP at " + $usedService | log
$currentIP = checkIP $usedService

try {
   if (([System.Environment]::OSVersion.Version.Major -eq 6) -and ([System.Environment]::OSVersion.Version.Minor -eq 1)) {
    "Resolve DNS Name " + "Using System.Net.Dns" | log
        # workaround for Windows 7/2008R2
        $ipHostEntry = [System.Net.Dns]::GetHostByName($fqdn)
        $registeredIP = ($ipHostEntry.AddressList).IPAddressToString 
    } else {
    "Resolve DNS Name " + "Using native Commandlet" | log
        $ipHostEntry = Resolve-DnsName $fqdn -Type A -ErrorAction Stop
        $registeredIP = $ipHostEntry[0].IPAddress
    }

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
        $resp = Invoke-WebRequest -Uri $url -Credential $myCreds -UseBasicParsing -ErrorAction Stop
    } catch {
        "Update DNS " + $_.Exception.Message | log
        exit 1
    }

    "SPDNS result " + $resp.Content | log

}

exit 0
