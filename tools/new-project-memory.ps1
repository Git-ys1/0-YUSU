param(
    [Parameter(Mandatory = $true)]
    [string]$Slug,

    [string]$ProjectName = "",
    [string]$ProjectPath = ""
)

$ErrorActionPreference = "Stop"

if ($Slug -notmatch "^[a-z0-9][a-z0-9-]*$") {
    throw "Slug must be lowercase letters/numbers/dashes, for example simple-oscilloscope."
}

$root = & (Join-Path $PSScriptRoot "resolve-kb-root.ps1")
$template = Join-Path $root "05_Templates\project-memory"
$target = Join-Path $root "01_Projects\$Slug"

if (Test-Path -LiteralPath $target) {
    throw "Project memory already exists: $target"
}

Copy-Item -LiteralPath $template -Destination $target -Recurse

$readme = Join-Path $target "README.md"
$content = Get-Content -LiteralPath $readme -Raw
$content = $content.Replace("- Project Name:", "- Project Name: $ProjectName")
$content = $content.Replace("- Project Slug:", "- Project Slug: $Slug")
$content = $content.Replace("- Primary Path:", "- Primary Path: $ProjectPath")
$content = $content.Replace("- Last Updated:", "- Last Updated: $(Get-Date -Format yyyy-MM-dd)")
Set-Content -LiteralPath $readme -Value $content -Encoding UTF8

Write-Output "Created: $target"

