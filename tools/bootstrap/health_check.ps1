Write-Host "============================="
Write-Host "ClaudeWatch Health Check"
Write-Host "============================="

function Run-Check {
    param([string]$name, [scriptblock]$action)
    Write-Host "Checking: $name..."
    try {
        & $action
        Write-Host "[PASS] $name" -ForegroundColor Green
    } catch {
        Write-Host "[FAIL] $name failed" -ForegroundColor Red
        exit 1
    }
}

Run-Check "flutter doctor" { flutter doctor -v }
Run-Check "flutter analyze" { flutter analyze }
Run-Check "flutter test" { flutter test }
Run-Check "flutter build apk" { flutter build apk --debug }
Run-Check "adb devices" { adb devices }
Run-Check "flutter devices" { flutter devices }

Write-Host "Health Check: ALL SYSTEMS GO" -ForegroundColor Green
