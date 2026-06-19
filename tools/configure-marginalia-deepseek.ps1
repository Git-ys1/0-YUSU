param(
    [string]$ApiKey = $env:DEEPSEEK_API_KEY,
    [string]$Model = "deepseek-v4-flash",
    [string]$BaseUrl = "https://api.deepseek.com"
)

$ErrorActionPreference = "Stop"

if (-not $ApiKey) {
    throw "Set DEEPSEEK_API_KEY or pass -ApiKey. The key is written only to ignored .marginalia-yusu/.env."
}

$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$runtimeDir = Join-Path $root ".marginalia-yusu"
$envFile = Join-Path $runtimeDir ".env"

New-Item -ItemType Directory -Force -Path $runtimeDir | Out-Null

$lines = @()
if (Test-Path -LiteralPath $envFile) {
    $lines = @(Get-Content -LiteralPath $envFile -Encoding UTF8)
}

$updates = [ordered]@{
    "LLM_DEFAULT_PROVIDER" = "openai-compatible"
    "LLM_DEFAULT_BASE_URL" = $BaseUrl
    "LLM_DEFAULT_API_KEY" = $ApiKey
    "LLM_DEFAULT_MODEL" = $Model
}

$seen = @{}
$next = foreach ($line in $lines) {
    $trim = $line.Trim()
    if ($trim -match "^(?<key>[A-Za-z_][A-Za-z0-9_]*)=") {
        $key = $Matches["key"]
        if ($updates.Contains($key)) {
            $seen[$key] = $true
            "$key=$($updates[$key])"
        } else {
            $line
        }
    } else {
        $line
    }
}

foreach ($key in $updates.Keys) {
    if (-not $seen.ContainsKey($key)) {
        $next += "$key=$($updates[$key])"
    }
}

Set-Content -LiteralPath $envFile -Encoding UTF8 -Value $next

Write-Output "Configured Marginalia LLM provider: openai-compatible"
Write-Output "Configured Marginalia LLM base URL: $BaseUrl"
Write-Output "Configured Marginalia LLM model: $Model"
Write-Output "Secret written only to ignored local file: $envFile"
