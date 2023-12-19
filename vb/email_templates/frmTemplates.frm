VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} frmTemplates 
   Caption         =   "DSU Mail Templates - v5.0 - RN"
   ClientHeight    =   6630
   ClientLeft      =   45
   ClientTop       =   345
   ClientWidth     =   4275
   OleObjectBlob   =   "frmTemplates.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "frmTemplates"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
' -------------------------------------------------------------------------------------------------------------------------------
' Roger Nem - Adapted from the original Template tool
'
' SRV1234567.hosting.domain.com
' \\SRV1234567\D$\DomainHQ\tools.domain.com\home
'
' version 5.0
' Last Update - No need of dat files
' -------------------------------------------------------------------------------------------------------------------------------

Private Declare Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" _
                   (ByVal hwnd As Long, ByVal lpszOp As String, _
                    ByVal lpszFile As String, ByVal lpszParams As String, _
                    ByVal LpszDir As String, ByVal FsShowCmd As Long) _
                    As Long

Dim strFileLocTemp As String
Dim strURLTemp As String
Dim arrMails() As String


Private Sub UserForm_Initialize()
    subRefresh
End Sub

Private Sub UserForm_QueryClose(Cancel As Integer, CloseMode As Integer)
    Me.Hide
    Cancel = True
End Sub

Public Sub subRefresh()
    Label5.Width = 0

    Set objFSO = CreateObject("Scripting.FileSystemObject")
    
    strFileLocTemp = "c:\temp\" 'Location of the Templates
    
    Set objFolder = objFSO.GetFolder(strFileLocTemp)
    
    Set colFiles = objFolder.Files
    For Each objFile In colFiles
        
        If (objFile.name) <> "links.txt" Then
        
            arrTemp = Split(objFile.name, ".oft")
            
            'Add the Items to the Listbox
            lstTemplates.AddItem arrTemp(0)
            lstTemplatesHidden.AddItem objFile.name
        
        End If
        
    Next
  
End Sub


Private Sub cmdDownload_Click()

    Dim totaltemplates As Integer
    Dim downloadedtemplates As Integer
    Dim percentage
    
    Dim strUsername As String
    Dim strPassword As String
    
    Dim pos As Integer
    Dim content As String
    Dim template_name As String
    Dim template_file As String
    
    Const ForReading = 1
    
    strUsername = txtUsername.Text
    strPassword = txtPassword.Text
    downloadedtemplates = 0
    
    MsgBox "Please wait until the download is finished!"

    ' -------------------------------------------------------------------------------------------------------------------------------
    ' 1 - Create file containing links to all templates
    ' -------------------------------------------------------------------------------------------------------------------------------
    With CreateObject("Microsoft.XMLHTTP")
      .Open "GET", "https://tools.domain.com/outlook/data/", False, strUsername, strPassword
      .Send
      GetXml = .responseText
    End With

    Set objFSO = CreateObject("Scripting.FileSystemObject")
    Set objFile = objFSO.CreateTextFile("C:\temp\links.txt", 2)
    'objFile.Write GetXml
    'objFile.Close

    ' Some Clean-up
    strNewText = Replace(GetXml, "<html><head><title>tools.domain.com - /outlook/data/</title></head><body><H1>tools.domain.com - /outlook/data/</H1><hr>", "")
    strNewText = Replace(strNewText, "<pre><A HREF=", "")
    strNewText = Replace(strNewText, ">[To Parent Directory]</A>", "")
    strNewText = Replace(strNewText, "</pre><hr></body></html>", "")
    strNewText = Replace(strNewText, vbCrLf, "")
    strNewText = Replace(strNewText, "<br>", vbCrLf)
        
    objFile.WriteLine strNewText
    objFile.Close
    ' -------------------------------------------------------------------------------------------------------------------------------

    ' -------------------------------------------------------------------------------------------------------------------------------
    ' 2 - Download the templates / Populate the list
    ' -------------------------------------------------------------------------------------------------------------------------------
    'clear list
    lstTemplates.Clear
    lstTemplatesHidden.Clear
    
    ' get the approximate total number of templates
    Set objTextFile = objFSO.OpenTextFile(strFileLocTemp & "links.txt", ForReading)
    objTextFile.ReadAll
    totaltemplates = objTextFile.Line
        
    ' read file content
    content = readFile("C:\temp\links.txt")

    ' search for links
    Do While InStr(content, "<A HREF")
        ' find begin of link
        pos = InStr(content, "<A HREF")
        content = Mid(content, pos + 7)

        ' find closing >
        pos = InStr(content, ">")
        content = Mid(content, pos + 1)

        ' find begin of closing tag
        pos = InStr(content, "<")

        ' print out link text
        template_name = Left(content, pos - 1)
        template_file = template_name & ".oft"

        ' Add the Items to the Listbox
        lstTemplates.AddItem template_name 'LAMP - Passwords - Shared
        lstTemplatesHidden.AddItem template_file 'LAMP - Passwords - Shared.oft
                    
        ' Download .oft Files
        SubDownload "c:\temp\" & template_file, "https://tools.domain.com/outlook/data/" & template_file, strUsername, strPassword

        ' shows the percentage
        downloadedtemplates = downloadedtemplates + 1
        percentage = downloadedtemplates * 100 / totaltemplates
        
        Label4.Caption = "Download Status: " & FormatNumber(Int(percentage * 100) / 100, 0) & "%"
        Label5.Width = FormatNumber(Int(percentage * 100) / 100, 0)

    Loop
    
    Label4.Caption = "Download Status: 100%"
    MsgBox "Download has finished. The tool can be used now!"

End Sub


Private Function readFile(ByVal pFile As String) As String
    Dim ret As String
    Dim row As String

    ' create file handle
    Dim hnd As Integer
    hnd = FreeFile

    ' open file
    Open pFile For Input As hnd

    ' read file
    Do Until EOF(hnd)
        Line Input #hnd, row
        ret = ret & row
    Loop

    ' close file
    Close hnd

    ' return content
    readFile = ret
End Function



Private Sub SubDownload(strFileSaveTo As String, strURL As String, strUsername As String, strPassword As String)
    
    Dim objXMLHTTP

    Set objXMLHTTP = CreateObject("Msxml2.ServerXMLHTTP.4.0")

    If strUsername = "" And strPassword = "" Then
        objXMLHTTP.Open "GET", strURL, False
    Else
        objXMLHTTP.Open "GET", strURL, False, strUsername, strPassword
    End If
    
    objXMLHTTP.Send

    Set oStream = CreateObject("Adodb.Stream")
    Const adTypeBinary = 1
    Const adSaveCreateOverWrite = 2
    Const adSaveCreateNotExist = 1
    
    DoEvents
    oStream.Type = adTypeBinary
    oStream.Open
    oStream.Write objXMLHTTP.responseBody

    oStream.savetofile strFileSaveTo, adSaveCreateOverWrite
    
    oStream.Close
    
    Set oStream = Nothing
    Set objXMLHTTP = Nothing
End Sub

' --------------------------------------------------------------------------------------------------------
' To open the template
' --------------------------------------------------------------------------------------------------------
Private Sub lstTemplates_DblClick(ByVal Cancel As MSForms.ReturnBoolean)
Set objFSO = CreateObject("Scripting.FileSystemObject")

    If lstTemplates.ListIndex <> -1 Then
            If objFSO.FileExists(strFileLocTemp & lstTemplates.Text & ".oft") Then
                ShellExecute 0, "open", strFileLocTemp & lstTemplates.Text & ".oft", "", strFileLocTemp, 0
            Else
                MsgBox strFileLocTemp & lstTemplates.Text & ".oft" & " does not exist"
            End If
        'End If
    End If

End Sub