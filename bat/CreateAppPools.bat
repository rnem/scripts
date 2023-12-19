:: BAT: Script to create App Pools
:: Created by Roger Nem - 2011

@Echo Off

ECHO creating Application Pool AppPoolBR.portalnest on %DATE% at %TIME%
"C:\Windows\System32\inetsrv\appcmd.exe" add apppool /name:AppPoolBR.portalnest /managedRuntimeVersion:v2.0 /managedPipelineMode:Classic>>2011100302634_CreateAppPools.log

ECHO creating Application Pool AppPool AppPoolBR.purina_dotNet2 on %DATE% at %TIME%
"C:\Windows\System32\inetsrv\appcmd.exe" add apppool /name:AppPoolBR.purina_dotNet2 /managedRuntimeVersion:v2.0 /managedPipelineMode:Classic>>2011100302634_CreateAppPools.log

ECHO Application Pool creation Complete on %DATE% at %TIME% 
ECHO --------------------- >>2011100302634_CreateAppPools.log 

pause

