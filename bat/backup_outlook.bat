:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: BAT: Script to backup Outlook PST files and save drafts
:: 
:: Description: This script safely backs up Outlook PST files by first saving
::              any open drafts, closing Outlook gracefully, creating dated
::              backups, and cleaning up old backup files.
::
:: Dependencies: Requires SaveDrafts.ps1 in the same directory
:: Usage: Run directly from Windows Explorer or command prompt
:: Retention: Keeps backups for 7 days, then automatically removes older files
::
:: Created by: Roger Nem
:: Date: 5/22/2025
:: Version: 1.0
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
echo Starting script execution...

:: Set base paths
set BASE_DIR=C:\_ROGER\Documents\Outlook Files
set BACKUP_DIR=%BASE_DIR%\Backup
set DEBUG_LOG=%BASE_DIR%\debug_log.txt

:: Set code page to Windows-1252 (Western European)
chcp 1252 > nul

:: Create debug log file directly from batch
set datepart=%date%
for /f "tokens=1,2 delims=:" %%a in ("%time%") do set timepart=%%a:%%b
echo %datepart% %timepart% - Script started > "%DEBUG_LOG%"

:: Create Backup directory if it doesn't exist
if not exist "%BACKUP_DIR%" (
    mkdir "%BACKUP_DIR%"
    set datepart=%date%
    for /f "tokens=1,2 delims=:" %%a in ("%time%") do set timepart=%%a:%%b
    echo %datepart% %timepart% - Created Backup directory >> "%DEBUG_LOG%"
)

:: Execute PowerShell script directly from file with UTF-8 encoding
echo Running PowerShell script to save drafts and close Outlook...
powershell -ExecutionPolicy Bypass -Command "& {[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; . '%BASE_DIR%\SaveOutlookDrafts.ps1'}" >nul
set datepart=%date%
for /f "tokens=1,2 delims=:" %%a in ("%time%") do set timepart=%%a:%%b
echo %datepart% %timepart% - PowerShell script executed >> "%DEBUG_LOG%"

:: Wait for Outlook to fully close
echo Waiting for Outlook to close completely...
timeout /t 10 /nobreak > nul
set datepart=%date%
for /f "tokens=1,2 delims=:" %%a in ("%time%") do set timepart=%%a:%%b
echo %datepart% %timepart% - Waited for Outlook to close >> "%DEBUG_LOG%"

:: Format date for backup filename
set mydate=%date:~4,2%-%date:~7,2%-%date:~12,2%
set datepart=%date%
for /f "tokens=1,2 delims=:" %%a in ("%time%") do set timepart=%%a:%%b
echo %datepart% %timepart% - Using date format: %mydate% >> "%DEBUG_LOG%"

:: Backup PST files
echo Backing up PST files...
for %%f in ("%BASE_DIR%\*.pst") do (
    echo Copying %%f...
    copy "%%f" "%BACKUP_DIR%\%%~nf-%mydate%%%~xf"
    if errorlevel 1 (
        echo Failed to copy %%f - will try to force close Outlook and retry
        taskkill /f /im outlook.exe 2>nul
        timeout /t 2 /nobreak > nul
        copy "%%f" "%BACKUP_DIR%\%%~nf-%mydate%%%~xf"
    )
    set datepart=%date%
    for /f "tokens=1,2 delims=:" %%a in ("%time%") do set timepart=%%a:%%b
    echo %datepart% %timepart% - Backed up %%f >> "%DEBUG_LOG%"
)

:: Delete old backups
echo Deleting old backups...
cd /d "%BACKUP_DIR%"
forfiles /m *.pst /d -7 /c "cmd /c del @path" 2>nul
cd /d "%BASE_DIR%"
set datepart=%date%
for /f "tokens=1,2 delims=:" %%a in ("%time%") do set timepart=%%a:%%b
echo %datepart% %timepart% - Deleted old backups >> "%DEBUG_LOG%"

:: Kill any remaining PowerShell processes
echo Cleaning up PowerShell processes...
taskkill /f /im powershell.exe >nul 2>&1
set datepart=%date%
for /f "tokens=1,2 delims=:" %%a in ("%time%") do set timepart=%%a:%%b
echo %datepart% %timepart% - Cleaned up PowerShell processes >> "%DEBUG_LOG%"

:: Wait longer before starting Outlook again
echo Waiting before starting Outlook...
timeout /t 10 /nobreak > nul

:: Start Outlook
echo Starting Outlook...
start outlook.exe
set datepart=%date%
for /f "tokens=1,2 delims=:" %%a in ("%time%") do set timepart=%%a:%%b
echo %datepart% %timepart% - Started Outlook >> "%DEBUG_LOG%"

set datepart=%date%
for /f "tokens=1,2 delims=:" %%a in ("%time%") do set timepart=%%a:%%b
echo %datepart% %timepart% - Script completed >> "%DEBUG_LOG%"
echo Script completed. Check debug_log.txt for details.
echo.
pause
