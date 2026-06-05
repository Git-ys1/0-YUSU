param(
    [int]$BatchSize = 4,
    [int]$Concurrency = 1,
    [int]$ProgressEvery = 25,
    [switch]$Resume,
    [switch]$UseLocalBge,
    [string]$EmbeddingBaseUrl = "http://127.0.0.1:8011/v1",
    [string]$EmbeddingApiKey = "local-bge-key"
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$toolRoot = Join-Path $root ".tools"
$runtimeDir = Join-Path $root ".marginalia-yusu"
$pythonExe = Join-Path $toolRoot "marginalia-venv\Scripts\python.exe"

if (-not (Test-Path -LiteralPath $pythonExe)) {
    throw "Marginalia is not installed. Run tools\setup-marginalia-yusu.ps1 first."
}

New-Item -ItemType Directory -Force -Path (Join-Path $toolRoot "tmp"), (Join-Path $runtimeDir "home") | Out-Null

$env:TEMP = Join-Path $toolRoot "tmp"
$env:TMP = $env:TEMP
$env:PIP_CACHE_DIR = Join-Path $toolRoot "pip-cache"
$env:HOME = Join-Path $runtimeDir "home"
$env:USERPROFILE = $env:HOME
$env:MARGINALIA_HOME = ((Join-Path $runtimeDir "data") -replace "\\", "/")

if ($UseLocalBge) {
    $env:EMBEDDING_PROVIDER = "openai-compatible"
    $env:EMBEDDING_BASE_URL = $EmbeddingBaseUrl
    $env:EMBEDDING_API_KEY = $EmbeddingApiKey
    $env:EMBEDDING_MODEL = "BAAI/bge-m3"
    $env:EMBEDDING_DIMENSIONS = "1024"
    $env:EMBEDDING_BATCH_SIZE = [string]$BatchSize
    $env:SEMANTIC_RECALL_ENABLED = "true"
}

$resumeArg = if ($Resume) { "--resume" } else { "" }
$script = @'
from __future__ import annotations

import argparse
import asyncio

from marginalia.db.bootstrap import bootstrap_schema
from marginalia.db.engine import dispose_engine
from marginalia.db.session import session_scope
from marginalia.semantic.index import DEFAULT_INDEX_NAME, build_semantic_index


async def run(args: argparse.Namespace) -> None:
    await bootstrap_schema()
    try:
        async with session_scope() as session:
            result = await build_semantic_index(
                session,
                index_name=args.index_name,
                batch_size=args.batch_size,
                concurrency=args.concurrency,
                resume=args.resume,
                progress_every=args.progress_every,
            )
        print("semantic index built")
        print(f"  index_dir: {result.index_dir}")
        print(f"  entries: {result.entries_indexed}")
        print(f"  model: {result.model}")
        print(f"  dimensions: {result.dimensions}")
        print(f"  elapsed_ms: {result.elapsed_ms}")
        print(f"  total_tokens: {result.total_tokens}")
    finally:
        await dispose_engine()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--index-name", default=DEFAULT_INDEX_NAME)
    parser.add_argument("--batch-size", type=int, default=4)
    parser.add_argument("--concurrency", type=int, default=1)
    parser.add_argument("--progress-every", type=int, default=25)
    parser.add_argument("--resume", action="store_true")
    asyncio.run(run(parser.parse_args()))


if __name__ == "__main__":
    main()
'@

Push-Location $runtimeDir
try {
    $argsList = @(
        "--batch-size", [string]$BatchSize,
        "--concurrency", [string]$Concurrency,
        "--progress-every", [string]$ProgressEvery
    )
    if ($resumeArg) {
        $argsList += $resumeArg
    }
    $script | & $pythonExe - @argsList
} finally {
    Pop-Location
}
