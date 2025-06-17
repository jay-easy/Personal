# Get the directory of the script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$logFile = Join-Path $scriptDirectory "NinjaRMMAgent.log"

# Function to log messages with timestamp
function Write-Log {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $Message"
    Write-Output $logEntry
    Add-Content -Path $logFile -Value $logEntry
}

# Check the status of NinjaRMMAgent service
$service = Get-Service -Name "NinjaRMMAgent" -ErrorAction SilentlyContinue

if ($null -eq $service) {
    Write-Log "Service NinjaRMMAgent not found."
    exit 1
}

switch ($service.Status) {
    'Running' {
        Write-Log "Service NinjaRMMAgent is already running."
    }
    'Paused' {
        Write-Log "Service NinjaRMMAgent is paused. Attempting to resume service..."
        try {
            $sc = New-Object System.ServiceProcess.ServiceController $service.Name
            $sc.Continue()
            Start-Sleep -Seconds 5
            $service.Refresh()
            if ($service.Status -eq 'Running') {
                Write-Log "Service NinjaRMMAgent resumed and running successfully."
            } else {
                Write-Log "Failed to resume NinjaRMMAgent service."
                exit 1
            }
        } catch {
            Write-Log "Error resuming NinjaRMMAgent service: $_"
            exit 1
        }
    }
    default {
        Write-Log "Service NinjaRMMAgent is in status: $($service.Status). Attempting to start service..."
        try {
            Start-Service -Name "NinjaRMMAgent"
            Start-Sleep -Seconds 5
            $service.Refresh()
            if ($service.Status -eq 'Running') {
                Write-Log "Service NinjaRMMAgent started successfully."
            } else {
                Write-Log "Failed to start NinjaRMMAgent service."
                exit 1
            }
        } catch {
            Write-Log "Error starting NinjaRMMAgent service: $_"
            exit 1
        }
    }
}
