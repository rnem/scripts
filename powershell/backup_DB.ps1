#####################################################################
# Script to backup databases 
# Created by Roger Nem on July 5, 2011
# Version 1.3
#####################################################################


$Host.UI.RawUI.WindowTitle = " -- DB backup --"

echo ""
$Host.UI.RawUI.WindowTitle = " -- DB backup | Loading assemblies --"
echo "1) Loading assemblies..."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
[System.Reflection.Assembly]::LoadFrom("D:\Tools\ROGER\Microsoft.SqlServer.SMO.dll")  | out-null 
[System.Reflection.Assembly]::LoadFrom("D:\Tools\ROGER\Microsoft.SqlServer.SmoExtended.dll")  | out-null 		
[System.Reflection.Assembly]::LoadFrom("D:\Tools\ROGER\Microsoft.SqlServer.ConnectionInfo.dll") | out-null 
[System.Reflection.Assembly]::LoadFrom("D:\Tools\ROGER\Microsoft.SqlServer.SqlEnum.dll") | out-null 
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlClrProvider") | out-null 
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.Sdk.Sfc")  | out-null

echo "Assemblies loaded."
echo ""

do{ 

   $Host.UI.RawUI.WindowTitle = " -- DB backup | Gathering Info --"
   echo "2) Gathering Info..."
   echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

   $dt = get-date -format yyyyMMddHHmm
   $SQLServer = read-host "Enter SQL Server Name where Database is"
   $DBName = read-host "Enter Database Name"
   $FilePath = "\\$SQLServer\d$\MSSQL\MSSQL.1\MSSQL\Backup"

   $File = $FilePath + "\" + $DBName + "_backup_" + $dt + ".bak"

   $Host.UI.RawUI.WindowTitle = " -- DB backup | Confirm provided Info --"
   echo ""   
   echo "3) Confirm information below"
   echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
   echo "Sql Server: $SQLServer"
   echo "Database Name: $DBName"
   echo ""

   $choice = Read-Host "Is everything correct? [Y]yes / [N]No"
   echo ""

}
until ($choice -eq “Y”)


$Host.UI.RawUI.WindowTitle = " -- DB backup | Backing up Database --"
echo "4) Backing up Database..."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

Function BackupDataBase([string] $DBName, [string] $DBServer, [string] $BackupFilePath )
{
    "Backup started. Please, be patient..."

    # get server
 	$server = New-Object -typeName ("Microsoft.SqlServer.Management.Smo.Server") -argumentList $SQLServer
	
	# get db
	$db = New-Object ("Microsoft.SqlServer.Management.Smo.Database")
	$db = $server.Databases.Item($DBName)	 
	
	# create backup object
	$bk = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Backup
	$bk.Action = [Microsoft.SqlServer.Management.Smo.BackupActionType]::Database
	$bk.BackupSetDescription = "Full backup of " + $DBName	
	$bk.Database = $DBName
	
	# set file location on the backupobject (path , type)
	$bk.Devices.AddDevice($BackupFilePath, 2) 
	
	$bk.Incremental = $FALSE
	$backupDate = new-object System.DateTime(2006, 10, 5)
	$bk.ExpirationDate = $backupDate
	$bk.LogTruncation = [Microsoft.SqlServer.Management.Smo.BackupTruncateLogType]::Truncate
	$bk.SqlBackup($server)
	
	$Host.UI.RawUI.WindowTitle = " -- DB backup | Backup is finished --"
	echo ""
    "Backup is finished!"
	"Backup can be retrieved at $File"

}

# Backup database with all information provided

BackupDataBase -DBName $DBName -DBServer $SQLServer -BackupFilePath $File
