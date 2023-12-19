#########################################################
# Extract information of groups from Active Directory   #
# by Roger Nem (2015)                                   #
#                                                       #
# History:                                              #
# v0.001  - Roger Nem - First Version                   #
#########################################################

Set-ExecutionPolicy Unrestricted -force
Get-ChildItem -Path 'E:\AD_Extract\jobs\' -Recurse | Unblock-File

$Headers= @{Label="Name";Expression={$_.Name}},
@{Label="Distinguished Name";Expression={$_.DistinguishedName}},
@{Label="Date Created";Expression={$_.Created}}

Get-ADGroup -Filter * -Properties Name, DistinguishedName,Created | Select $Headers | export-csv 'E:\AD_Extract\data\AD_Export_Groups.csv' -NoTypeInformation -Encoding UTF8

if ($Host.Name -eq 'ConsoleHost') {
    Stop-Process $PID
}
