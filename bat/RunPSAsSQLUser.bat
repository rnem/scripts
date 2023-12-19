:: BAT: Script to run PowerShell as SQL User
:: Created by Roger Nem - 2011

@echo off

set /p KID="Please, inform your konest ID: "

echo.
echo KONEST ID: %KID%

runas /user:konest\%KID% %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe
