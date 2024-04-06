#########################################################
# Extract redirection rules from IIS                    #
# by Roger Nem (2015)                                   #
#                                                       #
# History:                                              #
# v0.001  - Roger Nem - First Version                   #
#########################################################

# Check if the script is already running as administrator
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
$isElevated = $currentUser.IsInRole($adminRole)

# Check if the script is already running as administrator
if (-not $isElevated) {
    Write-Host "This script needs to be run as Administrator to access IIS configuration data."
    Write-Host "Please re-run the script by right-clicking on the PowerShell icon and selecting 'Run as administrator'."
    Exit

}else{

	# Import the WebAdministration module
	Import-Module WebAdministration

	# Get all sites in IIS
	$sites = Get-Website

	Write-Host "Site Name,Redirect URL"

	# Loop through each site
	foreach ($site in $sites) {
		$siteName = $site.Name
		$configPath = Join-Path $site.PhysicalPath "web.config"

		# Check if web.config file exists for the site
		if (Test-Path $configPath) {
			# Load web.config file as XML
			$webConfig = [xml](Get-Content $configPath)

			# Check for redirection rules in web.config
			$redirectionRules = $webConfig.configuration.'system.webServer'.httpRedirect
			if ($redirectionRules -ne $null) {
				$redirectUrl = $redirectionRules.destination
				Write-Host "$siteName,$redirectUrl"
				# Write-Host ""
			}
		}
	}
}