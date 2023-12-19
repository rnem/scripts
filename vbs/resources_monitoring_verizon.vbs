'########################################################################
'# Gather server resources (cpu | ram | hdd) info and export to an html #
'# file for monitoring. Not Asynchronous as the .aspx web application   #
'# Location: Verizon                                                    #
'# Created by Roger Nem - 2016                                          #
'# History:                                                             #
'# v0.001  - Roger Nem - First Version                                  #
'########################################################################

on error resume next
Dim intInterval
Dim xmlDoc
Dim strQuery
Dim colIntervals, objInterval
Dim colGroups, objGroup
Dim colThresholds, colThreshold
Dim intCPU
Dim intRAM
Dim intHDD
Dim objIE
Dim txtTable
Dim objDocument
Dim xmlFile
Dim strPageBody
Dim oW3SVC
Dim strServerName
Const ForReading = 1, ForWriting = 2, ForAppending = 8

Dim DBCPU
Dim DBRAM
Dim DBDriveC
Dim DBDriveD
Dim DBDriveE
Dim DBTotWC
Dim DBTotWCUp
Dim DBWhatWCDown

' List of servers to monitor
xmlFile = "C:\Users\username\Desktop\servers.xml"

StartIE()
'Read XML file
Set xmlDoc = CreateObject("Microsoft.XMLDOM")
xmlDoc.async = false
xmlDoc.Load(xmlFile)
if xmlDoc.parseError.errorcode <> 0 then
	wscript.echo "Error opening file"
else
	Do While 1 <> 2
        ' Create HTML header
        strPageBody = "<html><body><title>DSU Monitoring Dashboard</title><meta http-equiv=""refresh"" content=""60"" /><style>body{margin:0px;padding:20px}table{font-family: Arial; font-size: 10pt;border-spacing:0px;}</style>"
		strPageBody = strPageBody & "Last poll (Server Time): " & now() & " - This information is updated every minute"
		strPageBody = strPageBody & "<table border=""1"" width=100%>"
		strPageBody = strPageBody & "<tr bgcolor=""#7BA7E1""><th align=""left"" width=250>Server</th><th align=""center"" width=120>% CPU in use</th><th align=""center"" width=120>% RAM in use</th><th align=""left"" width=210><table><tr><td colspan=3 align=center>HDD (% Free)</td></tr><tr><td width=70 align=center>System</td><td width=70 align=center>Web</td><td width=70 align=center>Log</td></tr></table></th><th width=100><table><tr><td colspan=2 align=center>Web Containers</td></tr><tr><td align=center width=50>Total #</td><td align=center width=50># Up</td></tr></table></th><th>Web Containers Down</th></tr>"
		'Read XML file for changes since last poll
		Set xmlDoc = CreateObject("Microsoft.XMLDOM")
		xmlDoc.async = false
		xmlDoc.Load(xmlFile)
		
		'Get % values for INTERVAL, CPU, RAM and HDD
		intInterval = 300 'set a default value just in case in seconds - 120 / 60 = 2 minutes
		intCPU = .9 'default value, red flag if over - ie CPU% > 90%
		intRAM = .8 'default value, red flag if over - ie RAM in use > 80%
		intHDD = .1 'default value, red flag if under - ie HDD free space < 10%
		
		strQuery = "/servers/ (interval | cpu | ram | hdd)"
		Set colThresholds = xmlDoc.selectNodes(strQuery)
		For Each objThreshold in colThresholds
			select case objThreshold.nodeName
				case "interval"
					intInterval = objThreshold.text
				case "cpu"
					intCPU = objThreshold.text
				case "ram"
					intRAM = objThreshold.text
				case "hdd"
					intHDD = objThreshold.text
			end select
		Next
		
		'Get group and server names from XML file
		strQuery = "/servers/group/ (name | server)"
		Set colGroups = xmlDoc.selectNodes(strQuery)
		For Each objGroup in colGroups
			'objGroup.nodeName = Either "name" or "server"
			'objGroup.text = Will either be the group name or the server name
			select case objGroup.nodeName
				Case "name"
					strPageBody = strPageBody & "<tr bgcolor=""#CEDEF4""><td colspan=""6"" style=""font-size:14px;""><strong>" & objGroup.text & "</strong></td></tr>"
				Case "server"
					'wscript.echo objGroup.text
					strPageBody = strPageBody & "<tr><td>" & objGroup.text & "</td>"
					set objSvc = GetObject("winmgmts:{impersonationLevel=impersonate}//" & objGroup.text & "/root/cimv2")
					if CINT(err.number) = 0 then  'The CInt function converts an expression to type Integer.
						'Check CPU usage
						strColour = ""
						strValue = ""
						set objRet = objSvc.ExecQuery("select * from Win32_PerfFormattedData_PerfOS_Processor WHERE NAME=""_Total""")
						for each item in objRet
							
							if CINT(item.PercentProcessorTime) > CINT(intCPU*100) then
								strColour = "red"
							elseif CINT(item.PercentProcessorTime) > CINT(60) then
								strColour = "yellow"
							else
								strColour = "lightgreen"
							end if

							strValue = item.PercentProcessorTime & "%"
							DBCPU = item.PercentProcessorTime & "%"

							strPageBody = strPageBody & "<td align=center style=""background:" & strColour & """><font color=""" & strColourx & """>" & strValue & "</font></td>"
						next
						
						strColour = ""
						strValue = ""
						set objRet = objSvc.InstancesOf("win32_OperatingSystem")
						for each item in objRet
							'Check RAM if over 80% in use red flag
							if ((item.TotalVisibleMemorySize-item.FreePhysicalMemory)/item.TotalVisibleMemorySize)*100 > intRAM*100 then
								strColour = "red"
							elseif	((item.TotalVisibleMemorySize-item.FreePhysicalMemory)/item.TotalVisibleMemorySize)*100 > 60 then							
								strColour = "yellow"
							else
								strColour = "lightgreen"
							end if

							strValue = FormatNumber(((item.TotalVisibleMemorySize-item.FreePhysicalMemory)/item.TotalVisibleMemorySize)*100,0)& "%"
							DBRAM = FormatNumber(((item.TotalVisibleMemorySize-item.FreePhysicalMemory)/item.TotalVisibleMemorySize)*100,0)& "%"

							strPageBody = strPageBody & "<td align=center bgcolor=" & strColour & "><font color=""" & strColourx & """>" & strValue & "</font></td>"
						next
						
						'Check hard drive space if free space is less than 10% red flag
						strColour = ""
						strValue = ""
						strPageBody = strPageBody & "<td><table border=""0"" cellspacing=""0""><tr>"
						set objRet = objSvc.InstancesOf("win32_LogicalDisk")
						x=0
						for each item in objRet
							if item.DriveType = 3 then
								'Default is drive has enough space and is green
								
								if (item.FreeSpace/item.size)*100 <= intHDD*100 then
									'There is less than a certain % of drive space left
									strColour = "Red"
								elseif 30 <= (item.FreeSpace/item.size)*100 And (item.FreeSpace/item.size)*100 <=40 then   'If (LowerBound <= Value) AndAlso (Value<=UpperBound) Then
									strColour = "yellow"
								else
									strColour = "lightgreen"
								end if

								strValue = item.caption & " " & FormatNumber((item.FreeSpace/item.size)*100,0) & "%"
								
								if x=0 then 
									DBDriveC = FormatNumber((item.FreeSpace/item.size)*100,0) & "%"
								elseif x=1 then 
									DBDriveD = FormatNumber((item.FreeSpace/item.size)*100,0) & "%"
								elseif x=2 then 
									DBDriveE = FormatNumber((item.FreeSpace/item.size)*100,0) & "%"
									x=0
								end if
								x = x + 1

								strPageBody = strPageBody & "<td align=center width=70 bgcolor=""" & strColour & """><font color=""" & strColourx & """>" & strValue & "</font></td>"
							end if
						next
						strPageBody = strPageBody & "</tr></table></td>"

						strServerName = objGroup.text
						Set oW3SVC = GetObject("IIS://" & strServerName & "/W3SVC") 'Get the IIS Server Object
						If (Err <> 0) Then
							strPageBody = strPageBody & "<td colspan=3>Error</td>"
						Else	

							Dim objWeb, numWC, numWCUp, numWCDown, WCsDown
							'numWC = 1
							For Each objWebServer In oW3SVC
 								If objWebServer.class = "IIsWebServer" Then

									Set objWeb = GetObject(objWebServer.adsPath & "/Root")

									If InStr(1, objWebServer.ServerComment, "FTP.") > 0 then
									
									Else
										numWC = numWC + 1
									End If									

									If objWebServer.Status = 4 Then ' down
										
										If InStr(1, objWebServer.ServerComment, "FTP.") > 0 then
										Else											
											WCsDown = WCsDown & objWebServer.ServerComment & ", "

											' Send Alert
											strSubject = UCase(strServerName) & " - Alert - Web Container(s) Down"
											strBody = Now & vbCrLf & objWebServer.ServerComment & " - web container is down" & vbCrLf 
											'call MAILER(strServerName, strSubject, strBody)

										End If
									elseif objWebServer.Status = 2 Then ' running
										numWCUp = numWCUp + 1																																										
									End If			
								End If
							Next

							If Len(WCsDown) Then
								strColourWC = "red"
								fontColor = "white"
							else
								strColourWC = "lightgreen"
								fontColor = "black"
							End If

							'Check # of Web Containers
							strPageBody = strPageBody & "<td><table><tr><td width=50 align=center>" & numWC & "</td><td width=50 align=center bgcolor=""" & strColourWC & """><font color=""" & fontColor & """>" & numWCUp & "</font></td></tr></table></td>"

							DBTotWC = numWC
							DBTotWCUp = numWCUp
							numWC = 0

							'Check # Up
							'strPageBody = strPageBody & "<td>" & numWCUp & "</td>"

							DBTotWC = numWCUp
							numWCUp = 0

							'Check Web Containers Down
							strPageBody = strPageBody & "<td bgcolor=""" & strColourWC & """><font color=""" & fontColor & """>" & WCsDown & "</font></td>"
							DBWhatWCDown = WCsDown
							WCsDown = ""

						End If

						strPageBody = strPageBody & "</tr>"

					else
						strPageBody = strPageBody & "<td colspan=""6""><font color=""red"">Server could not be reached</font></td></tr>"
					end if
					'err.clear

'Const adOpenStatic = 3
'Const adLockOptimistic = 3
'Set objConnection = CreateObject("ADODB.Connection")
'Set objRecordSet = CreateObject("ADODB.Recordset")

'objConnection.Open _
'    "Provider=SQLOLEDB;Data Source=DAC38997SQL200;" & _
'        "Trusted_Connection=Yes;Initial Catalog=DSU_MONITORING;" & _
'             "User ID=DSUSQL;Password=8j*oq57v;"

'objConnection.Execute "INSERT INTO Availability (ComputerName, [When], DBCPU, DBRAM, DBDriveC, DBDriveD, DBDriveE, DBTotWC, DBTotWCUp, DBWhatWCDown)" &  _
' "VALUES ('"& Trim(strServerName) &"', '"& now() &"', '"& DBCPU &"', '"& DBRAM &"', '"& DBDriveC &"', '"& DBDriveD &"', '"& DBDriveE &"', '"& DBTotWC &"', '"& DBTotWCUp &"', '"& DBWhatWCDown &"');"

			end select
		Next
		strPageBody = strPageBody & "</table></body></html>"
		
		
		'HTML page
		objDocument.body.innerHTML = ""
		objDocument.Writeln strPageBody
		
		'Create html page
        
		Set oFile2 = CreateObject("Scripting.FileSystemObject")
		Set oTextFile = oFile2.OpenTextFile("C:\Users\username\Desktop\index.html", ForWriting, true)
			
		oTextFile.WriteLine(strPageBody)
		oTextFile.Close

 		Set oTextFile = Nothing
 		Set oFile2 = Nothing

		'Repeat every X minutes
		wscript.sleep intInterval*1000
		
	loop
end if

' Functions
Sub StartIE()
	Dim objWshShell
	Set objIE = CreateObject("InternetExplorer.Application")
	objIE.menubar = false
	objIE.toolbar = false
	objIE.statusbar = false
	objIE.addressbar = false
	objIE.resizable = true
	objIE.navigate ("about:blank")
	While (objIE.busy)
	wend
	set objDocument = objIE.document 
	objDocument.Open
	objIE.visible = True
End Sub


Sub MAILER(Computer, Subject, Body)
	Set objEmail = CreateObject("CDO.Message")
	objEmail.From = strFrom & "no-reply@dsu.monitoring.com"
	objEmail.To = "me@domain.com; otherpersons@domain.com"
	objEmail.Subject = Subject
	objEmail.TextBody = Body
	objEmail.Send
End sub

FUNCTION State2Desc( nState )
    SELECT CASE nState
    CASE 1
        State2Desc = "Starting"
    CASE 2
        State2Desc = "Started"
    CASE 3
        State2Desc = "Stopping"
    CASE 4
        State2Desc = "Stopped"
    CASE 5
        State2Desc = "Pausing"
    CASE 6
        State2Desc = "Paused"
    CASE 7
        State2Desc = "Continuing"
    CASE ELSE
        State2Desc = "Unknown"
    END SELECT 
END FUNCTION