param(
    [string]$HostAddress = "127.0.0.1",
    [int]$Port = 8010,
    [string]$PythonPath = "",
    [string]$LocalApiKey = "local-llm-key",
    [string]$Model = "gpt-5.4",
    [string]$UpstreamBaseUrl = "",
    [string]$UpstreamApiKey = ""
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$toolRoot = Join-Path $root ".tools"
$serverScript = Join-Path $root "tools\codex-proxy-chat-completions-shim.py"

if ([string]::IsNullOrWhiteSpace($PythonPath)) {
    $PythonPath = Join-Path $toolRoot "marginalia-venv\Scripts\python.exe"
}
$pythonExe = (Resolve-Path -LiteralPath $PythonPath).Path

if (-not [string]::IsNullOrWhiteSpace($UpstreamBaseUrl)) {
    $env:YUSU_LLM_UPSTREAM_BASE_URL = $UpstreamBaseUrl
}
if (-not [string]::IsNullOrWhiteSpace($UpstreamApiKey)) {
    $env:YUSU_LLM_UPSTREAM_API_KEY = $UpstreamApiKey
}
$env:YUSU_LLM_SHIM_API_KEY = $LocalApiKey
$env:YUSU_LLM_MODEL = $Model

Write-Host "==> Starting Codex proxy LLM shim"
Write-Host "    endpoint: http://$HostAddress`:$Port/v1/chat/completions"
Write-Host "    model:    $Model"

& $pythonExe $serverScript --host $HostAddress --port $Port
