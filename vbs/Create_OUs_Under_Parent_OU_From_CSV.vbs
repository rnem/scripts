' Create_OUs_Under_Parent_OU_From_CSV.vbs
' VBScript to create OUs from a CSV file under a parent OU
' Example: System Accounts (parent OU)
'		DOMAINBR
'		DOMAINCA
'		etc.
' Author: Roger Nem
' Jan 19, 2016 - 1.0 - Initial version
' ------------------------------------------------------' 
 
' Variables 
Dim varParentOU, varDomain, varFileName, objFSO, objFile, objDomain2, objOU, strObject 
Dim strType, objConnection, objCommand, objRecordSet, successEx, ADPath, strLevel

Const ADS_SCOPE_SUBTREE = 2
Const ForReading = 1


'Provide Parent OU via Inputbox
Do While varParentOU = ""
	varParentOU = InputBox("What is the parent OU ?" & vbcrlf & "(e.g. Web Developers, Service Accounts, System Accounts, etc.)", "Please provide the Parent OU")
	If varParentOU = False Then
		Msgbox "Aborted by User"
		Wscript.Quit 
	ElseIf varParentOU <> "" Then
		result = Msgbox("Is '" & varParentOU & "' the correct parent OU?", vbYesNo, "Confirm Parent OU")
		Select Case result
		Case vbYes
			if(  distinguish(varParentOU, varParentOU,"organizationalUnit","Parent") <> ""  ) then
				MsgBox("The OUs will be created now. Please wait.")
			else
    				MsgBox("The parent Organizational Unit '" & varParentOU &"' doesnt't exist. Please verify.")
				varParentOU = ""
			end if
		Case vbNo
    			varParentOU = ""			
		End Select
	End If

Loop

 
' Modify this name to match your company's AD domain 
varDomain="domainrack.local" 
 
' Specify the csv file full path.
varFileName = "C:\temp\OUs.txt"

' Open the file for reading.
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.OpenTextFile(varFileName, ForReading)

' Read the first line
objFile.ReadLine

'Uncomment to troubleshoot
on error GoTo 0
'on error resume next

' Read the file and create new OU
Do Until objFile.AtEndOfStream

    	varOuName = objFile.ReadLine

	if(  distinguish(varParentOU, varOuName,"organizationalUnit","Child") <> ""  ) then
		MsgBox ("Organizational Unit '" & varOuName & "' already exists under the parent OU '"& varParentOU &"' and it will not be created")
	else
		' Create new OUs
		Set objDomain2 = GetObject("LDAP://OU=" & varParentOU & ",DC=DOMAINRACK,DC=local")
		Set objOU = objDomain2.Create("organizationalUnit", "OU=" & varOuName)
		objOU.SetInfo
		successEx = 1
	end if
Loop


If Err.Number <> vbEmpty Then
	WScript.Echo "Error:   Creation failed. " & Err
Else
	if successEx = 1 then
		WScript.Echo "Success: New Organizational Unit(s) created."
	else
		WScript.Echo "Nothing done."
	end if
End If


Function distinguish(varParentOU, strObject, strType, strLevel)

    Select case strType 
        Case lcase("computer") 
            strobject = strobject & "$" 
        Case lcase("user") 
            'Good 
        Case lcase("group") 
            'Good 
        Case ("organizationalUnit") 
            'Good 
		if strLevel = "Child" then
			ADPath = "LDAP://OU=" & varParentOU & ",DC=DOMAINRACK,DC=local"
		else
			ADPath = "LDAP://DC=DOMAINRACK,DC=local"
		end if
        Case else 
            Wscript.Echo "Their is an error in the script" 
    End Select 

    Set objConnection = createObject("ADODB.Connection") 
    Set objCommand = createObject("ADODB.Command") 
    objConnection.Provider = "ADsDSOObject" 
    objConnection.Open "Active Directory Provider" 
     
    Set objCommand.ActiveConnection = objConnection 
    'objCommand.CommandText = "Select distinguishedname, Name from 'LDAP://OU=" & varParentOU & ",DC=DOMAINRACK,DC=local' WHERE (&(objectCategory=organizationalUnit)(objectClass=organizationalUnit)(ou=" & strobject & ")) "  

    objCommand.CommandText = "Select distinguishedname, Name, Location from '" & ADPath & "' Where objectClass='" & strType & "' AND objectCategory='organizationalUnit' and OU='" & strobject & "'" 

    objCommand.Properties("Page Size") = 1000 
    objCommand.Properties("Searchscope") = 2  
    Set objRecordSet = objCommand.execute 
    
if (not objRecordSet.bof and not objRecordSet.eof) then
    objRecordSet.MoveFirst 
end if
    Do Until objRecordSet.EOF 
       distinguish = objRecordSet.Fields("distinguishedname") 
       objRecordSet.MoveNext 
    Loop 


 
End Function

WScript.Quit