$tools = @("flutter", "dart", "git", "java", "adb", "sdkmanager", "gh", "claude", "gemini")

Write-Host "============================="
Write-Host "ClaudeWatch Bootstrap Audit"
Write-Host "============================="

$allPassed = $true

foreach ($tool in $tools) {
    $cmd = Get-Command $tool -ErrorAction SilentlyContinue
    if ($cmd) {
        Write-Host "[PASS] $tool is installed ($($cmd.Source))" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] $tool is missing from PATH" -ForegroundColor Red
        $allPassed = $false
    }
}

# MCP servers check (Placeholder since they are context specific to the IDE)
$mcpDir = "$env:USERPROFILE\.gemini\antigravity-ide\mcp"
if (Test-Path $mcpDir) {
    Write-Host "[PASS] MCP directory exists" -ForegroundColor Green
} else {
    Write-Host "[WARNING] MCP directory not found at $mcpDir" -ForegroundColor Yellow
}

Write-Host "============================="
if ($allPassed) {
    Write-Host "Bootstrap Complete: READY" -ForegroundColor Green
} else {
    Write-Host "Bootstrap Complete: MISSING DEPENDENCIES" -ForegroundColor Red
}
