# Start the .NET Functions API in a new PowerShell window
Write-Host "Starting Azure Functions API..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\api'; Write-Host 'Starting Azure Functions on http://localhost:7071...' -ForegroundColor Yellow; func start"

# Wait for the API to start up
Write-Host "Waiting for API to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Check if the API is responding
Write-Host "Checking if API is ready..." -ForegroundColor Yellow
$apiReady = $false
$maxAttempts = 10
$attempt = 0

while (-not $apiReady -and $attempt -lt $maxAttempts) {
    try {
        # Use longer timeout and more robust settings
        $response = Invoke-WebRequest -Uri "http://localhost:7071/api/live" -Method GET -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $apiReady = $true
            Write-Host "✅ API is ready! (Status: $($response.StatusCode))" -ForegroundColor Green
        } else {
            $attempt++
            Write-Host "API returned status $($response.StatusCode), attempt $attempt/$maxAttempts..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
    catch [System.Net.WebException] {
        $attempt++
        Write-Host "Connection error, attempt $attempt/$maxAttempts... (API might be starting up)" -ForegroundColor Yellow
        Start-Sleep -Seconds 3
    }
    catch {
        $attempt++
        Write-Host "API not ready yet, attempt $attempt/$maxAttempts... ($($_.Exception.Message))" -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }
}

if (-not $apiReady) {
    Write-Host "⚠️  API might not be ready, but continuing anyway..." -ForegroundColor Yellow
}

# Start the SWA CLI
Write-Host "Starting SWA CLI..." -ForegroundColor Green
Write-Host "Your app will be available at: http://localhost:4280" -ForegroundColor Cyan
npx @azure/static-web-apps-cli start