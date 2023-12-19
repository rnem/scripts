'*  Script Name:   DeleteOldBRBackups.vbs
'*  Created On:    26/April/2012
'*  Author:        Roger Nem

'Account used to run script needs delete permissions to folder & files.

'Set the following variables
BackupFolderPath = "D:\Backup\domainbr" 'no trailing backslash
NumberOfDays = 10 'anything older than this many days will be removed

'Set objects & error catching
On Error Resume Next
Dim fso
Dim objFolder
Dim objFile
Dim objSubfolder
Set fso = CreateObject("Scripting.FileSystemObject")
Set objFolder = fso.GetFolder(BackupFolderPath)

'DELETE all files in Backup Folder Path older than x days
For Each objFile In objFolder.files
    If DateDiff("d", objFile.DateCreated,Now) > NumberOfDays Then
        objFile.Delete True
        End If
Next

'DELETE all subfolders in Backup Folder Path older than x days
For Each objSubfolder In objFolder.Subfolders
    If DateDiff("d", objSubfolder.DateCreated,Now) > NumberOfDays Then
            objSubfolder.Delete True     
        End If
Next