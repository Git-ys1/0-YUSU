param(
    [string]$CarbonRagRoot = "F:\Project\CarbonRag",
    [string]$PythonPath = "",
    [string]$HostAddress = "127.0.0.1",
    [int]$Port = 8011,
    [string]$ApiKey = "local-bge-key"
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$serverScript = Join-Path $root "tools\carbonrag-bge-openai-embedding-server.py"
$carbonRoot = (Resolve-Path -LiteralPath $CarbonRagRoot).Path

if ([string]::IsNullOrWhiteSpace($PythonPath)) {
    $PythonPath = Join-Path $carbonRoot "backend\.conda\python.exe"
}
$pythonExe = (Resolve-Path -LiteralPath $PythonPath).Path
$modelCache = Join-Path $carbonRoot "data\outputs\models"
$modelDir = Join-Path $modelCache "BAAI\bge-m3"

if (-not (Test-Path -LiteralPath $modelDir)) {
    throw "BGE-M3 model directory not found: $modelDir"
}

$env:CARBONRAG_ROOT = $carbonRoot
$env:RAG_MODEL_CACHE_DIR = $modelCache
$env:RAG_EMBEDDING_PROVIDER = "bge_m3"
$env:RAG_EMBEDDING_MODEL = "BAAI/bge-m3"
$env:RAG_EMBEDDING_DEVICE = "cpu"
$env:RAG_MODEL_AUTO_DOWNLOAD = "false"
$env:BGE_EMBEDDING_API_KEY = $ApiKey

Write-Host "==> Starting CarbonRag BGE-M3 embedding shim"
Write-Host "    endpoint: http://$HostAddress`:$Port/v1/embeddings"
Write-Host "    model:    BAAI/bge-m3"
Write-Host "    dims:     1024"
Write-Host "    root:     $carbonRoot"

& $pythonExe $serverScript `
    --host $HostAddress `
    --port $Port `
    --carbonrag-root $carbonRoot `
    --model-cache-dir $modelCache
