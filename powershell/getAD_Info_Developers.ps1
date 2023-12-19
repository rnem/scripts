##############################################################
# Extract information of developers from Active Directory    #
# by Roger Nem (2015)                                        #
#                                                            #
# History:                                                   #
# v0.001  - Roger Nem - First Version                        #
##############################################################

Set-ExecutionPolicy Unrestricted -force
Get-ChildItem -Path 'E:\AD_Extract\jobs\' -Recurse | Unblock-File

$maxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days

$Headers= @{Label="OU Path";Expression={$_.CanonicalName}},
@{Label="Distinguished Name";Expression={$_.DistinguishedName}},
@{Label="Name";Expression={$_.DisplayName}},
@{Label="AD Account";Expression={$_.SAMAccountName}},
@{Label="E-mail";Expression={$_.EmailAddress}},
@{Label="Date Created";Expression={$_.Created}},
@{Label="Last Logon Date";Expression={$_.LastLogOnDate}},
@{Label="Last Password Change";Expression={$_.PasswordLastSet}},
@{Label="Expiry Date";Expression={$_.PasswordLastSet.AddDays($maxPasswordAge)}},
@{Label="Password Never Expires?";Expression={$_.PasswordNeverExpires}},
@{Label="Enabled?";Expression={$_.Enabled}},
@{Label="Locked Out?";Expression={$_.LockedOut}}

Get-ADUser -SearchBase "OU=Web Developers,DC=domain,DC=local" -Filter * -Properties CanonicalName,DistinguishedName,DisplayName,SamAccountName,EmailAddress,Created,LastLogOnDate,PasswordLastSet,PasswordNeverExpires,Enabled,LockedOut | Select $Headers | export-csv 'E:\AD_Extract\data\AD_Export_Developers.csv' -NoTypeInformation -Encoding UTF8

if ($Host.Name -eq 'ConsoleHost') {
    Stop-Process $PID
}

