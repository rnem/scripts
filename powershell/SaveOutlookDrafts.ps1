#==============================================================================
# PowerShell: Outlook Draft Saver and Graceful Shutdown Utility
#
# Description: This script connects to a running Outlook instance, saves all
#              open drafts and inspector windows, then gracefully closes Outlook.
#              It's designed to be called from backup_outlook.bat but can also
#              be run independently.
#
# Functions:
#   - Detects if Outlook is already running
#   - Saves all open draft emails and inspector windows
#   - Closes all inspector windows gracefully
#   - Shuts down Outlook properly to release file locks
#   - Provides detailed logging of all operations
#
# Created by: Roger Nem
# Date: 5/22/2025
# Version: 1.0
#==============================================================================

# Set output encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Set base paths
$baseDir = "C:\_ROGER\Documents\Outlook Files"
$debugLog = "$baseDir\debug_log.txt"

# Get the exact date format from batch file
function Get-BatchDateFormat {
    $dayOfWeek = (Get-Date).DayOfWeek.ToString().Substring(0,3)
    $date = (Get-Date).ToString("MM/dd/yyyy")
    $time = (Get-Date).ToString("HH:mm")
    return "$dayOfWeek $date $time"
}

Add-Content -Path $debugLog -Value "$(Get-BatchDateFormat) - PowerShell script started" -Encoding UTF8

try {
    # Check if Outlook is already running
    $outlookProcess = Get-Process -Name "OUTLOOK" -ErrorAction SilentlyContinue
    $outlookWasRunning = ($outlookProcess -ne $null)
    
    if ($outlookWasRunning) {
        Add-Content -Path $debugLog -Value "$(Get-BatchDateFormat) - Outlook already running, connecting to existing instance" -Encoding UTF8
    } else {
        Add-Content -Path $debugLog -Value "$(Get-BatchDateFormat) - Starting new Outlook instance" -Encoding UTF8
        # Start Outlook if it's not running
        Start-Process "outlook.exe" -WindowStyle Minimized
        Start-Sleep -Seconds 5
    }
    
    Add-Content -Path $debugLog -Value "$(Get-BatchDateFormat) - Connecting to Outlook" -Encoding UTF8
    $outlook = New-Object -ComObject Outlook.Application -ErrorAction Stop
    Add-Content -Path $debugLog -Value "$(Get-BatchDateFormat) - Connected to Outlook" -Encoding UTF8
    
    # First save all open items in inspectors
    $inspectors = $outlook.Inspectors
    Add-Content -Path $debugLog -Value "$(Get-BatchDateFormat) - Found $($inspectors.Count) open inspector windows" -Encoding UTF8
    
    # Create a list to store all open inspectors
    $openInspectors = @()
    foreach($inspector in $inspectors) {
        try {
            $item = $inspector.CurrentItem
            if($item -ne $null) {
                $openInspectors += $inspector
                $item.Save()
                Add-Content -Path $debugLog -Value "$(Get-BatchDateFormat) - Saved active item: $($item.Subject)" -Encoding UTF8
            }
        } catch {
            Add-Content -Path $debugLog -Value "$(Get-BatchDateFormat) - Error accessing inspector: $_" -Encoding UTF8
        }
    }
    
    # Save any unsaved drafts in the Drafts folder
    $namespace = $outlook.GetNamespace('MAPI')
    $drafts = $namespace.GetDefaultFolder(16)
    Add-Content -Path $debugLog -Value "$(Get-BatchDateFormat) - Accessed drafts folder" -Encoding UTF8
    
    foreach($item in $drafts.Items) {
        if($item.Saved -eq $false) {
            $item.Save()
            Add-Content -Path $debugLog -Value "$(Get-BatchDateFormat) - Saved draft: $($item.Subject)" -Encoding UTF8
        }
    }
    
    # Close all open inspector windows gracefully
    Add-Content -Path $debugLog -Value "$(Get-BatchDateFormat) - Closing all open inspector windows" -Encoding UTF8
    foreach($inspector in $openInspectors) {
        try {
            $inspector.Close(1) # olDiscard = 1
            Add-Content -Path $debugLog -Value "$(Get-BatchDateFormat) - Closed inspector window" -Encoding UTF8
        } catch {
            Add-Content -Path $debugLog -Value "$(Get-BatchDateFormat) - Error closing inspector: $_" -Encoding UTF8
        }
    }
    
    # Give time for inspectors to close
    Start-Sleep -Seconds 2
    
    # Now quit Outlook gracefully
    Add-Content -Path $debugLog -Value "$(Get-BatchDateFormat) - Closing Outlook gracefully" -Encoding UTF8
    $outlook.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($outlook)
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    
    # Wait to ensure Outlook has time to close properly
    Start-Sleep -Seconds 5
    
    # Check if Outlook is still running, only force close as last resort
    $outlookProcess = Get-Process -Name "OUTLOOK" -ErrorAction SilentlyContinue
    if ($outlookProcess) {
        Add-Content -Path $debugLog -Value "$(Get-BatchDateFormat) - Outlook still running, waiting 5 more seconds" -Encoding UTF8
        Start-Sleep -Seconds 5
        
        # Check again before force closing
        $outlookProcess = Get-Process -Name "OUTLOOK" -ErrorAction SilentlyContinue
        if ($outlookProcess) {
            Add-Content -Path $debugLog -Value "$(Get-BatchDateFormat) - Outlook still running after wait, force closing as last resort" -Encoding UTF8
            $outlookProcess | ForEach-Object { $_.CloseMainWindow() | Out-Null }
            Start-Sleep -Seconds 2
            $outlookProcess = Get-Process -Name "OUTLOOK" -ErrorAction SilentlyContinue
            if ($outlookProcess) {
                $outlookProcess | ForEach-Object { $_.Kill() }
            }
        }
    }
    
    Add-Content -Path $debugLog -Value "$(Get-BatchDateFormat) - Successfully completed Outlook operations" -Encoding UTF8
} 
catch {
    Add-Content -Path $debugLog -Value "$(Get-BatchDateFormat) - Error: $_" -Encoding UTF8
    Add-Content -Path $debugLog -Value "$(Get-BatchDateFormat) - Error details: $($_.Exception)" -Encoding UTF8
    Add-Content -Path $debugLog -Value "$(Get-BatchDateFormat) - Stack trace: $($_.ScriptStackTrace)" -Encoding UTF8
}
