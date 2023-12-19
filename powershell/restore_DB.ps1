#####################################################################
# Script to restore databases 
# Created by Roger Nem on July 6, 2011
# Version 1.4
#####################################################################

$Host.UI.RawUI.WindowTitle = " -- DB Restore --"

echo ""
$Host.UI.RawUI.WindowTitle = " -- DB Restore | Loading assemblies --"
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

   $Host.UI.RawUI.WindowTitle = " -- DB Restore | Gathering Info --"
   echo "2) Gathering Info..."
   echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

   $dt = get-date -format yyyyMMddHHmm
   $SQLServer = read-host "Enter SQL Server where database is going to be restored"
   $DBName = read-host "Enter the Database Name"

   $BkFileToBeRestored = read-host "Enter the Full Path of the Backup File to be restored"

   # info to auto generate the backup
   # --------------------------------------------------------------------------------------	
   $FilePath = "\\$SQLServer\d$\MSSQL\MSSQL.1\MSSQL\Backup"
   $File = $FilePath + "\" + $DBName + "_backup_" + $dt + ".bak"
   # --------------------------------------------------------------------------------------	

   $Host.UI.RawUI.WindowTitle = " -- DB Restore | Confirm provided Info --"
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


$Host.UI.RawUI.WindowTitle = " -- DB Restore | Backing up Database First --"
echo "4) Backing up Database First..."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

Function BackupDataBase([string] $DBName, [string] $DBServer, [string] $BackupFilePath )
{
       "Backup started. Please, be patient..."

Trap {
  $err = $_.Exception
  while ( $err.InnerException )
    {
    $err = $err.InnerException
    write-output $err.Message
    };
    continue
  }

    # get server
 	$server = New-Object -typeName ("Microsoft.SqlServer.Management.Smo.Server") -argumentList $DBServer

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
}

# Backup database with all information provided

BackupDataBase -DBName $DBName -DBServer $SQLServer -BackupFilePath $File


$Host.UI.RawUI.WindowTitle = " -- DB Restore | Restoring Database --"
echo ""
echo "5) Generating Scripts to be used in the restore ..."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | out-null
$MyScripter=new-object ("Microsoft.SqlServer.Management.Smo.Scripter")
$srv=New-Object "Microsoft.SqlServer.Management.Smo.Server" $SQLServer
$MyScripter.Server=$srv

$ScriptsPath = $FilePath
$database = $srv.Databases[$DBName]

#write-host "Getting the script to recreate the users of" $DBName
$fu = [System.IO.Path]::Combine($ScriptsPath, $DBName + "_users_" + $dt + ".sql")
$MyScripter.options.IncludeDatabaseContext = $false
$e = "USE " + $DBName
out-file -filePath $fu -inputobject $e
out-file -filePath $fu -inputobject "GO" -Append
foreach ($User in $database.Users) {
	if ($User.Name -ne "sys" -and $User.Name -ne "dbo" -and $User.Name -ne "INFORMATION_SCHEMA" -and $User.Name -ne "guest") {
		$MyScripter.Options.IncludeIfNotExists = $true
		$MyScripter.Options.ScriptDrops = $true
		$MyScripter.Script($User) | Out-file $fu -append
	}	

	if ($User.Name -ne "sys" -and $User.Name -ne "dbo" -and $User.Name -ne "INFORMATION_SCHEMA" -and $User.Name -ne "guest") {
		$MyScripter.options.IncludeDatabaseContext = $false
		$MyScripter.Options.ScriptDrops = $false
		$MyScripter.Script($User) | Out-file $fu -append
		out-file -filePath $fu -inputobject "`n" -append
	}
}

#write-host "Getting the script to add every user to its roles..."
$f = [System.IO.Path]::Combine($ScriptsPath, $DBName + "_roles_" + $dt + ".sql")
$e = "USE " + $DBName
out-file -filePath $f -inputobject $e
out-file -filePath $f -inputobject "GO" -Append
foreach ($role in $database.Roles) {
	if ($role.Name -ne "public") {
		foreach ($member in $role.EnumMembers()) {
			if ($member -ne "dbo") {
				$var = "sys.sp_addrolemember @rolename = N'" + $role.Name+"', @membername = N'"+$member+"'"
				out-file -filePath $f -inputobject $var -append
				out-file -filePath $f -inputobject "GO" -append
			}
		}
	}
}

echo "Scripts generated!"


$Host.UI.RawUI.WindowTitle = " -- DB Restore | Restoring Database --"
echo ""
echo "6) Restoring Database Now..."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"



Function RestoreDataBase([string] $DBName,
                         [string] $DBServer, 
			 [string] $BackupFile){
        
Trap {
  $err = $_.Exception
  while ( $err.InnerException )
    {
    $err = $err.InnerException
    write-output $err.Message
    };
    continue
  }

	# get server
	$server = New-Object -typeName Microsoft.SqlServer.Management.Smo.Server ($SQLServer)

	# Copy database locally if backup file is on a network share
	$BackupFile = [IO.Path]::GetFileName($BkFileToBeRestored)
	$localPath = "\\$SQLServer\d$\MSSQL\MSSQL.1\MSSQL\Backup\$BackupFile" 
	Copy-Item $BkFileToBeRestored $localPath
	$backupFilePath = $localPath

	# Create restore object and specify its settings
	$smoRestore = new-object("Microsoft.SqlServer.Management.Smo.Restore")
	$smoRestore.Database = $DBName
	$smoRestore.NoRecovery = $false;
	$smoRestore.ReplaceDatabase = $true;
	$smoRestore.Action = "Database"

	# Create location to restore from
	$backupDevice = New-Object("Microsoft.SqlServer.Management.Smo.BackupDeviceItem") ($backupFilePath, "File")
	$smoRestore.Devices.Add($backupDevice)

	# Provide paths where mdf and ldf files are stored
	$sqlDataPath = "d:\MSSQL\MSSQL.1\MSSQL\Data" 
	$sqlLogDataPath = "f:\MSSQL\Data"

	# Specify new data file (mdf)
	$smoRestoreDataFile = New-Object("Microsoft.SqlServer.Management.Smo.RelocateFile")
	$smoRestoreDataFile.PhysicalFileName = 	$sqlDataPath +"\"+ $DBName + "_Data.mdf" 

	# Specify new log file (ldf)
	$smoRestoreLogFile = New-Object("Microsoft.SqlServer.Management.Smo.RelocateFile")
	$smoRestoreLogFile.PhysicalFileName = $sqlLogDataPath +"\"+ $DBName + "_Log.ldf" 

	# Get the file list from backup file
    $dbFileList = $smoRestore.ReadFileList($server)

	# The logical file names should be the logical filename stored in the backup media
	$smoRestoreDataFile.LogicalFileName = $dbFileList.Select("Type = 'D'")[0].LogicalName
	$smoRestoreLogFile.LogicalFileName = $dbFileList.Select("Type = 'L'")[0].LogicalName

	# Add the new data and log files to relocate to
	$smoRestore.RelocateFiles.Add($smoRestoreDataFile)
	$smoRestore.RelocateFiles.Add($smoRestoreLogFile)
 
	# Restore the database
	$smoRestore.SqlRestore($server)

	# Roda as duas queries para os users
	Invoke-sqlcmd -ServerInstance $SQLServer -Database $DBName -InputFile "\\$SQLServer\d$\MSSQL\MSSQL.1\MSSQL\Backup\$fu"; 
	Invoke-sqlcmd -ServerInstance $SQLServer -Database $DBName -InputFile "\\$SQLServer\d$\MSSQL\MSSQL.1\MSSQL\Backup\$f";

    "Database restore completed successfully"    
}

RestoreDataBase -DBName $DBName -DBServer $SQLServer -BackupFile $BkFileToBeRestored