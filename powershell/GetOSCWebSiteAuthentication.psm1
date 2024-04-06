<#
The sample scripts are not supported under any Microsoft standard support 
program or service. The sample scripts are provided AS IS without warranty  
of any kind. Microsoft further disclaims all implied warranties including,  
without limitation, any implied warranties of merchantability or of fitness for 
a particular purpose. The entire risk arising out of the use or performance of  
the sample scripts and documentation remains with you. In no event shall 
Microsoft, its authors, or anyone else involved in the creation, production, or 
delivery of the scripts be liable for any damages whatsoever (including, 
without limitation, damages for loss of business profits, business interruption, 
loss of business information, or other pecuniary loss) arising out of the use 
of or inability to use the sample scripts or documentation, even if Microsoft 
has been advised of the possibility of such damages.
#>

#requires -Version 2

#Import Localized Data
Import-LocalizedData -BindingVariable Messages

Function New-OSCPSCustomErrorRecord
{
	#This function is used to create a PowerShell ErrorRecord
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true,Position=1)][String]$ExceptionString,
		[Parameter(Mandatory=$true,Position=2)][String]$ErrorID,
		[Parameter(Mandatory=$true,Position=3)][System.Management.Automation.ErrorCategory]$ErrorCategory,
		[Parameter(Mandatory=$true,Position=4)][PSObject]$TargetObject
	)
	Process
	{
		$exception = New-Object System.Management.Automation.RuntimeException($ExceptionString)
		$customError = New-Object System.Management.Automation.ErrorRecord($exception,$ErrorID,$ErrorCategory,$TargetObject)
		return $customError
	}
}

Function Test-OSCUserPrivilege
{
	$windowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()  
	$windowsPrincipal = New-Object -TypeName System.Security.Principal.WindowsPrincipal($windowsIdentity)  
	$Administrator = [System.Security.Principal.WindowsBuiltInRole]::Administrator  
	$isElevated = $windowsPrincipal.IsInRole($Administrator)
	if ($isElevated) {
		return $true
	} else {
		return $false
	}
}

Function Get-OSCWebSiteAuthentication
{
	#.EXTERNALHELP Get-OSCWebSiteAuthentication-Help.xml
	
	[CmdletBinding()]
	Param
	(
		#Define parameters
		[Parameter(Mandatory=$false,Position=1,ValueFromPipeline=$true)]
		[string[]]$ComputerName=@($env:COMPUTERNAME),
		[Parameter(Mandatory=$false,Position=2)]
		[System.Management.Automation.PSCredential]$Credential,
		[Parameter(Mandatory=$false)]
		[switch]$IncludeRawAuthenticationData		
	)
	Process
	{
		if (-not (Test-OSCUserPrivilege)) {
			$errorMsg = $Messages.RequiresElevation
			$customError = New-OSCPSCustomErrorRecord `
			-ExceptionString $errorMsg `
			-ErrorCategory NotSpecified -ErrorID 1 -TargetObject $pscmdlet
			$pscmdlet.ThrowTerminatingError($customError)
		}
        
		#Authentication modes that be checked, Forms authetication will be handled separately.
		$authenticationClasses = @("Anonymous","Basic","ClientCertificateMapping","Digest","IisClientCertificateMapping","Windows")

        #Prepare connection options before establishing WMI connections.
		$connectionOptions = New-Object System.Management.ConnectionOptions
		if ($Credential -ne $null) {
			$connectionOptions.Username = $Credential.UserName
			$connectionOptions.SecurePassword = $Credential.Password
		}
        
		$connectionOptions.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
        
		#Iterate each sever to retrive authentication data
		foreach ($serverName in $ComputerName) {
			#Try to eastablish WMI connection
			Try
			{
				$verboseMsg = $Messages.EstablishConnection
				$verboseMsg = $verboseMsg -f $serverName
				$pscmdlet.WriteVerbose($verboseMsg)			
			    #$managementScope = New-Object System.Management.ManagementScope("\\$($serverName)\root\MicrosoftIISv2",$connectionOptions)
                #$managementScope = New-Object System.Management.ManagementScope("\\$($serverName)\root\cimv2",$connectionOptions)
                $managementScope = New-Object System.Management.ManagementScope("\\$($serverName)\root\webadministration",$connectionOptions)
				$managementScope.Connect()
				$connectionEstablished = $managementScope.IsConnected
			}
			Catch
			{
				$pscmdlet.WriteError($Error[0])
				$connectionEstablished = $false
			}
			if ($connectionEstablished) {
				#Get Web Sites
				$queryString = "Select * From Site"
				$objectQuery = New-Object System.Management.ObjectQuery($queryString)
				$moSearcher = New-Object System.Management.ManagementObjectSearcher($managementScope,$objectQuery)
				$moObserver = New-Object System.Management.ManagementOperationObserver
				$webSites = $moSearcher.Get()
                
				#Handle following error if remote server does not contain any web site.
				#Error: An error occurred while enumerating through a collection: Cannot get collection count.
				if ($webSites -eq $null) {
					$errorMsg = $Messages.ZeroWebSites
					$errorMsg = $errorMsg -f $serverName
					$customError = New-OSCPSCustomErrorRecord `
					-ExceptionString $errorMsg `
					-ErrorCategory NotSpecified -ErrorID 1 -TargetObject $pscmdlet
					$pscmdlet.WriteError($customError)					
				} else {
					#Iterate each web site
					foreach ($webSite in $webSites) {
						$mboAutheSections = @()
						#Get web site authentication section
						$webSiteAutheSection = $webSite.GetSection("AuthenticationSection")
						foreach ($authenticationClass in $authenticationClasses) {
							$className = "$($authenticationClass)AuthenticationSection"
							$mboAutheSections += $webSite.GetSection($className).Section
						}
						#Handle Forms authencation
						if ($webSiteAutheSection.Section.Mode -eq 3) {
							$mboAutheSections += $webSiteAutheSection.Section
						}
                        
						#Prepare output for server which can establish connection
                        # This will throw error in case there are problems with the web.config file. This needs to be put on a try catch (Code Improvement)
						foreach ($mboAutheSection in $mboAutheSections) {
							$report = New-Object System.Management.Automation.PSObject
                            
                            $bindname = $webSite.bindings.BindingInformation
                            $siteUrl1,$siteurl2=$bindname.split(",")
                            $domainName=$siteUrl1.Trim([char]0x007B, [char]0x002A, [char]0x003A, [char]0x0038, [char]0x0030)
							
                            $authenticationName = $mboAutheSection.__Class.Replace("AuthenticationSection","")
							$report | Add-Member -MemberType NoteProperty -Name ComputerName -Value $serverName
							$report | Add-Member -MemberType NoteProperty -Name Connection -Value "Establsihed"
							$report | Add-Member -MemberType NoteProperty -Name WebSiteName -Value $webSite.Name
                            $report | Add-Member -MemberType NoteProperty -Name Bindings -Value $domainName
                            
							if ($authenticationName -ne "") {
								$report | Add-Member -MemberType NoteProperty -Name Authentication -Value $authenticationName
								$report | Add-Member -MemberType NoteProperty -Name Enabled -Value $mboAutheSection.Enabled
							} else {
								$report | Add-Member -MemberType NoteProperty -Name Authentication -Value "Forms"
								$report | Add-Member -MemberType NoteProperty -Name Enabled -Value $true
							}
                            
							if ($IncludeRawAuthenticationData) {
								$report | Add-Member -MemberType NoteProperty -Name AuthenticationSection -Value $mboAutheSection
							}
                            
                            #$report2 is variable which removes all the web names containing "REUSE" word. Input is $report.
                            $report2 = $report | ? {$_ -Notmatch 'reuse'}
                            $pscmdlet.WriteObject($report2)
						}
					}
				}
			} else {
				#Prepare output for server which cannot establish connection
				$report = New-Object System.Management.Automation.PSObject
				$report | Add-Member -MemberType NoteProperty -Name ComputerName -Value $serverName
				$report | Add-Member -MemberType NoteProperty -Name Connection -Value "Not Establsihed"
				$report | Add-Member -MemberType NoteProperty -Name WebSiteName -Value "N/A"
                $report | Add-Member -MemberType NoteProperty -Name Bindings -Value "N/A"
				$report | Add-Member -MemberType NoteProperty -Name Authentication -Value "N/A"
				$report | Add-Member -MemberType NoteProperty -Name Enabled -Value "N/A"
				if ($IncludeRawAuthenticationData) {
					$report | Add-Member -MemberType NoteProperty -Name AuthenticationSection -Value "N/A"
				}
                #$report2 is variable which removes all the web names containing "REUSE" word. Input is $report.
                $report2 = $report | ? {$_ -Notmatch 'reuse'}
                $pscmdlet.WriteObject($report2)
			}
		}
	}
}