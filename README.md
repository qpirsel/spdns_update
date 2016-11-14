### What is it for?
This script is intended to be used for the Securepoint Dynamic DNS Service (https://www.spdyn.de/).

### Something special with this script?
The script tries to contact the service only if necessary to avoid a ban due a high request count. But because of it's router independent pre check function you can execute it every 5 minutes with the Windows Task Scheduler without any risks.

### How to install
Due to the extended security restrictions of PowerShell scripts the easiest way is to copy & paste the code.

1. open Powershell ISE
2. paste the code
3. adjust your values
4. save it as a *.ps1 file
5. execute the script

### Values
**$fqdn** Your fully qualified domain name, e.g. home.spdns.de  
**$user** Your username at spdns.de  
**$pwd** Your password at spdns.de  

### Logging (optional)
This script has an optional logging function for simple debugging purposes. Change **$logging = $true** to enable it.  
Ensure proper write permissions in the given folder structure. The log file itself will be created if missing.

### FAQ
Q: I get a _...execution of scripts is disabled on this system._ error when executing the script. What can I do?  
A: Open PowerShell as administrator paste **set-executionpolicy remotesigned** and confirm it.  
  
Q: Does the script work with tokens?    
A: Yes. A token is nothing else but an password that only works with the desired FQDN. Note: When you generate a token $user MUST be equal to your FQDN!
