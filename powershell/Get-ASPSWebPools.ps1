<#
.Synopsis
   This script gathers web pool data and log it. 
.DESCRIPTION
   After GetOSCWebSiteAuthentication.ps1 module is imported,
   check is done over all the application pools on triggered
   machine and data are collected and logged to FNAS store.
.EXAMPLE
   Execute it. Error handling will do the rest, if something fails.
.NOTES
   Author: Roger Nem
   Actual version: 1.00
   Change Log:

      +--------------+---------+-----------+-----------------------------+
      |     Date     | Version | VerizonID |           Changes           |
      +--------------+---------+-----------+-----------------------------+
      |  2016-05-12  |   1.00  |  Kopemi2  |       Initial version       |
      +--------------+---------+-----------+-----------------------------+
      |  2017-01-31  |   1.10  |  Kopemi2  |        Remote calling       |
      +--------------+---------+-----------+-----------------------------+
#>

#Do not delete the empty line above this one. It will break the script. Really.
#Create some variables for script function
#
# Script Header
# Try to set window title. If ISE, do not set and continue
if (! $psISE)
    {
    [System.Console]::Title = 'Get ASPS Web Pools'
}
#

#==========================================================================================
# Set Standard operating variables
#==========================================================================================
$date = Get-Date -Format MM-dd-yyyy
#$DTcenter = $env:ComputerName.Remove(3)
$fnaspath = '\\'+ $env:ComputerName +  "\E$\StagingScript\results\"
$fnaspath2 = $fnaspath + 'Get-ASPSWebPools'
$filename = $env:ComputerName + "-" + 'MERGED' + '-' + $date + '.txt'
$filename2 = $env:ComputerName + "-" + $date + '.txt'
$localpath = "E:\StagingScript\LocallySavedResults\"
$localfull = $localpath + $filename
$remotefull = $fnaspath2 + '\' + $filename2
$Stagingmod = '\\'+ $env:ComputerName + "\E$\StagingScript\GetOSCWebSiteAuthentication.psm1"


#Try to load a module
If (Test-Path $Stagingmod) {
    Import-Module $Stagingmod -Verbose
}
Else {
    Write-Host -Message 'Unable to import module. Is module PRESENT in path `$Stagingmod ?'
    Exit
}

#Try to access the path for logging and run the rest of the code if everything passed

#Test the path. If failed, try to create the folder
If ( ! (Test-Path $fnaspath)) {
        Get-OSCWebSiteAuthentication -ErrorAction Inquire -Verbose | 
        Format-Table -AutoSize -Property ComputerName,WebSiteName,Authentication,Enabled,Bindings '|
        Out-File -FilePath $localfull -Force'
}
Else {
 
    #Everything passed, run the following check the following command
    If ( ! (Test-Path ($fnaspath + 'Get-ASPSWebPools'))) {

        Write-Host -ForegroundColor Yellow "Remote path accessible, but folder does not exist. Trying to create one..."
        try {
            New-Item -ItemType Directory -Path ($fnaspath2) -Force
        }
        #If creation of folder failed for any reason, throw an error and quit
        catch [System.IO.IOException]
            {
            Write-Host -Message "Unable to create local folder and `$fnaspath was unavailable as a target."
            Exit
        }

        #If everything is correct and folder was created, run the following command
        Get-OSCWebSiteAuthentication -ErrorAction Inquire -Verbose | 
        Format-Table -AutoSize -Property ComputerName,WebSiteName,Authentication,Enabled,Bindings |
        Out-File -FilePath $remotefull -Force
    }
    Else {

        #If everthing is ok this is what will run
        Get-OSCWebSiteAuthentication -ErrorAction Inquire -Verbose | 
        Format-Table -AutoSize -Property ComputerName,WebSiteName,Authentication,Enabled,Bindings |
        Out-File -FilePath $remotefull -Force
    }
}