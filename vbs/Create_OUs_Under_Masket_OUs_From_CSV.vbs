' Create_OUs_Under_Masket_OUs_From_CSV.vbs
' VBScript to create OUs from a CSV file under a Market OU
' Example: DOMAINBR (parent OU)
'		Deploy Users
'		Deploy Groups
'		etc.
' Author: Roger Nem
' Jul 7, 2016 - 1.0 - Initial version
' ------------------------------------------------------' 

'Declarations
Dim strDesktop, objFSO, objInputFile, parentOU, OU2BCreated, objRoot, objDomain
Dim objDomain2, objOU, objParent, strObject, strType, objConnection, objCommand, objRecordSet, strLevel

Const ForWriting = 2
Const ForAppending = 8
Const ForReading = 1

strDesktop = "C:\Users\username\Desktop\"

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objInputFile = objFSO.OpenTextFile(strDesktop & "MarketOUs.csv", ForReading)
'CSV (Market OU, New OU to be created):
'DOMAINAR,Deploy Groups
'DOMAINAE,Deploy Groups
'etc

Do Until objInputFile.AtEndOfStream

	strLine = objInputFile.ReadLine
	arrFields = Split(strLine, ",")

	'arrFields(0) = Market OU
	'arrFields(1) = OU to be created

	parentOU = trim(arrFields(0))
	OU2BCreated = trim(arrFields(1))

	call CreateSubOU(parentOU,OU2BCreated)

Loop
objInputFile.Close


Sub CreateSubOU(varParentOU,varOU2BCreated)

'Set obj = GetObject("LDAP://OU=IaaS Managed Devices,OU=DOMAINAE,OU=Web Developers,DC=domainrack,DC=local") 
'Set objACL = obj.get("nTSecurityDescriptor") 
'Set objDACL = objACL.DiscretionaryAcl 
'Set ace = CreateObject("AccessControlEntry") 
'For Each ace In objDACL 
'	output = "ACEName: " & ace.Name & ",ACEType: " & ace.AceType & ", ACEFlags: " & ace.AceFlags & ", Mask: " & ace.AccessMask
'	MsgBox ("All: " & output )
'Next
'wscript.quit

	'Const ADS_RIGHT_DS_DENY_DELETE = &H1
	'Const ADS_RIGHT_DS_DELETE_TREE = &H40

	'MsgBox ("varParentOU=" & varParentOU & ",New=" & varOU2BCreated)
	'OU=Deploy Users,OU=DOMAINAE,OU=Web Developers,DC=domainrack,DC=local

	'Object to copy the NT Security - Prevent from Deletion
	set obj = GetObject("LDAP://OU=IaaS Managed Devices,OU=DOMAINAE,OU=Web Developers,DC=domainrack,DC=local")
	set oSD = obj.Get("ntSecurityDescriptor")

	Set objParent = GetObject("LDAP://OU=" & varParentOU & ",OU=Web Developers,DC=domainrack,DC=local")
	Set objOU = objParent.Create("organizationalUnit", "OU=" & varOU2BCreated)
	objOU.Put "ntSecurityDescriptor", oSD
	
	objOU.SetInfo

End Sub