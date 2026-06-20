param(
    [Parameter(Mandatory = $true)]
    [string]$Video,
    [string]$OutputRoot = ".tools\video-analysis",
    [string]$Slug = "",
    [int]$IntervalSeconds = 8,
    [int]$MaxFrames = 40,
    [switch]$ExtractAudio,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Resolve-Tool {
    param(
        [string]$Name,
        [string]$EnvName,
        [string[]]$KnownPaths
    )

    $envValue = [Environment]::GetEnvironmentVariable($EnvName)
    if ($envValue -and (Test-Path -LiteralPath $envValue)) {
        return (Resolve-Path -LiteralPath $envValue).Path
    }

    $pathHit = Get-Command $Name -ErrorAction SilentlyContinue
    if ($pathHit) {
        return $pathHit.Source
    }

    foreach ($candidate in $KnownPaths) {
        if (Test-Path -LiteralPath $candidate) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    throw "Could not find $Name. Set $EnvName or install a project-local ffmpeg/ffprobe."
}

function New-Slug {
    param([string]$Path)
    $name = [IO.Path]::GetFileNameWithoutExtension($Path)
    $slug = $name -replace "[^\p{L}\p{Nd}]+", "-"
    $slug = $slug.Trim("-")
    if (-not $slug) { return "video" }
    return $slug
}

function Get-FrameRate {
    param([string]$Rate)
    if (-not $Rate -or $Rate -eq "0/0") { return $null }
    $parts = $Rate.Split("/")
    if ($parts.Count -eq 2 -and [double]$parts[1] -ne 0) {
        return [math]::Round(([double]$parts[0] / [double]$parts[1]), 3)
    }
    return $Rate
}

$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$videoPath = (Resolve-Path -LiteralPath $Video).Path
if (-not $Slug) { $Slug = New-Slug $videoPath }

$outputBase = if ([IO.Path]::IsPathRooted($OutputRoot)) {
    $OutputRoot
} else {
    Join-Path $root $OutputRoot
}
$outputDir = Join-Path $outputBase $Slug
if ((Test-Path -LiteralPath $outputDir) -and -not $Force) {
    throw "Output already exists: $outputDir. Pass -Force to replace it."
}
if (Test-Path -LiteralPath $outputDir) {
    Remove-Item -LiteralPath $outputDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

$ffmpeg = Resolve-Tool `
    -Name "ffmpeg" `
    -EnvName "FFMPEG_PATH" `
    -KnownPaths @("F:\Project\HyperFrames\node_modules\@ffmpeg-installer\win32-x64\ffmpeg.exe")
$ffprobe = Resolve-Tool `
    -Name "ffprobe" `
    -EnvName "FFPROBE_PATH" `
    -KnownPaths @("F:\Project\HyperFrames\node_modules\@ffprobe-installer\win32-x64\ffprobe.exe")

$metadataJsonPath = Join-Path $outputDir "metadata.json"
& $ffprobe -v error -print_format json -show_format -show_streams $videoPath | Set-Content -LiteralPath $metadataJsonPath -Encoding UTF8
$metadata = Get-Content -LiteralPath $metadataJsonPath -Raw | ConvertFrom-Json

$videoStream = @($metadata.streams | Where-Object { $_.codec_type -eq "video" } | Select-Object -First 1)[0]
$audioStreams = @($metadata.streams | Where-Object { $_.codec_type -eq "audio" })
$duration = [double]$metadata.format.duration
$sampleCount = [math]::Min($MaxFrames, [math]::Max(1, [math]::Ceiling($duration / [math]::Max(1, $IntervalSeconds))))
$columns = [math]::Min(5, [math]::Max(1, [math]::Ceiling([math]::Sqrt($sampleCount))))
$rows = [math]::Max(1, [math]::Ceiling($sampleCount / $columns))

$framesDir = Join-Path $outputDir "frames"
New-Item -ItemType Directory -Force -Path $framesDir | Out-Null
$framePattern = Join-Path $framesDir "frame_%03d.jpg"
& $ffmpeg -hide_banner -loglevel error -y -i $videoPath -vf "fps=1/$IntervalSeconds,scale=420:-1" -frames:v $sampleCount $framePattern
$actualFrameCount = @(Get-ChildItem -LiteralPath $framesDir -File -Filter "frame_*.jpg").Count
if ($actualFrameCount -gt 0) {
    $sampleCount = $actualFrameCount
}

$sheetPath = Join-Path $outputDir "contact-sheet.jpg"
& $ffmpeg -hide_banner -loglevel error -y -i $videoPath -vf "fps=1/$IntervalSeconds,scale=360:-1,tile=${columns}x${rows}:padding=8:margin=8:color=0x111111" -frames:v 1 $sheetPath

if ($ExtractAudio -and $audioStreams.Count -gt 0) {
    $audioPath = Join-Path $outputDir "audio-preview.wav"
    & $ffmpeg -hide_banner -loglevel error -y -i $videoPath -t 180 -vn -ac 1 -ar 16000 $audioPath
}

$timelineRows = @()
for ($i = 0; $i -lt $sampleCount; $i++) {
    $seconds = $i * $IntervalSeconds
    $time = [TimeSpan]::FromSeconds($seconds)
    $frameName = "frames/frame_$('{0:D3}' -f ($i + 1)).jpg"
    $timelineRows += "| $($time.ToString('hh\:mm\:ss')) | ``$frameName`` |  |  |  |  |  | |"
}

$summary = @"
# Video Analysis Workspace

Video: ``$videoPath``
Output: ``$outputDir``
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Technical Facts

| Field | Value |
|---|---|
| Duration | $([TimeSpan]::FromSeconds($duration).ToString('hh\:mm\:ss\.ff')) |
| Resolution | $($videoStream.width)x$($videoStream.height) |
| Frame rate | $(Get-FrameRate $videoStream.avg_frame_rate) |
| Video codec | $($videoStream.codec_name) |
| Audio streams | $($audioStreams.Count) |
| Audio codecs | $((@($audioStreams | ForEach-Object { $_.codec_name }) -join ", ")) |
| Sampling interval | ${IntervalSeconds}s |
| Sampled frames | $sampleCount |
| Contact sheet | `contact-sheet.jpg` |

## Required Human/Agent Read

Do not stop at the contact sheet. Open the frames, watch/skim the original video around unclear timestamps, and fill the table below before using this video as design or product evidence.

| Time | Frame | What is on screen? | What changed from previous beat? | Motion/interaction | Copy/message | Reusable lesson | Must not copy |
|---|---|---|---|---|---|---|---|
$($timelineRows -join "`n")

## Synthesis Gate

- Intent of the video:
- Audience/use case:
- Visual system:
- Information architecture:
- Motion language:
- Content modules:
- Things the target project should adopt:
- Things the target project should reject:
- Evidence used beyond screenshots:
- Remaining uncertainty:

## Completion Gate

- [ ] Metadata inspected.
- [ ] Contact sheet inspected.
- [ ] Individual frames inspected for at least every major visual beat.
- [ ] Audio/transcript considered when audio exists.
- [ ] Timeline table filled with concrete observations.
- [ ] Synthesis separates reusable patterns from content that must not be copied.
- [ ] Target implementation was checked against the synthesis, not just against isolated screenshots.
"@

$summaryPath = Join-Path $outputDir "analysis.md"
$summary | Set-Content -LiteralPath $summaryPath -Encoding UTF8

[pscustomobject]@{
    Video = $videoPath
    Output = $outputDir
    Metadata = $metadataJsonPath
    ContactSheet = $sheetPath
    Analysis = $summaryPath
    Frames = $framesDir
    DurationSeconds = [math]::Round($duration, 3)
    Resolution = "$($videoStream.width)x$($videoStream.height)"
    AudioStreams = $audioStreams.Count
    SampledFrames = $sampleCount
} | Format-List
