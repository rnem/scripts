#########################################################
# Extract information of users from Active Directory    #
# by Roger Nem (2015)                                   #
#                                                       #
# History:                                              #
# v0.001  - Roger Nem - First Version                   #
#########################################################

Set-ExecutionPolicy Unrestricted -force
Get-ChildItem -Path 'E:\AD_Extract\jobs\' -Recurse | Unblock-File

$maxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days

$Headers= @{Label="Distinguished Name";Expression={$_.DistinguishedName}},
@{Label="OU Path";Expression={$_.CanonicalName.Split("/")[1]}},
@{Label="Market";Expression={ if( $_.CanonicalName.Split("/")[2].IndexOf("AMS") -gt -1  -Or $_.CanonicalName.Split("/")[2].IndexOf("AOA") -gt -1  -Or $_.CanonicalName.Split("/")[2].IndexOf("EUR") -gt -1 -Or $_.CanonicalName.Split("/")[2].IndexOf("TECHM") -gt -1 -Or $_.CanonicalName.Split("/")[2].IndexOf("NESTLE") -gt -1 ){ $_.CanonicalName.Split("/")[2] }else{ 'N/A' }   }},
@{Label="Type";Expression={if ($_.CanonicalName.Split("/").Count -ge 5) { $_.CanonicalName.Split("/")[3] } else { 'N/A' }}},
@{Label="Name";Expression={$_.DisplayName}},
@{Label="AD Account";Expression={$_.SAMAccountName}},
@{Label="E-mail";Expression={$_.EmailAddress}},
@{Label="Nestle E-mail?";Expression={ if( $_.EmailAddress.ToLower().IndexOf("nestle.") -gt -1) { 'YES' } else { 'NO' } }},
#@{Label="MemberOf";Expression={ $_.MemberOf | % { (Get-ADGroup $_).Name }  }},
@{Label="MemberOf";Expression={ $_.MemberOf -replace '^CN=([^,]+).+$','$1;'  }},
@{Label="Date Created";Expression={$_.Created}},
@{Label="Last Logon Date";Expression={$_.LastLogOnDate}},
@{Label="Last Password Change";Expression={$_.PasswordLastSet}},
@{Label="Expiry Date";Expression={$_.PasswordLastSet.AddDays($maxPasswordAge)}},
@{Label="Password Never Expires?";Expression={$_.PasswordNeverExpires}},
@{Label="Enabled?";Expression={$_.Enabled}},
@{Label="Locked Out?";Expression={$_.LockedOut}}

Get-ADUser -Filter * -Properties CanonicalName,DistinguishedName,DisplayName,SamAccountName,EmailAddress,MemberOf,Created,LastLogOnDate,PasswordLastSet,PasswordNeverExpires,Enabled,LockedOut | Select-Object $Headers | export-csv 'E:\AD_Extract\data\AD_Export_All_Users_v3.csv' -NoTypeInformation -Encoding UTF8

if ($Host.Name -eq 'ConsoleHost') {
    #Stop-Process $PID
}

