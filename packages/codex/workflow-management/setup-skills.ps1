[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ContextRoot,

    [ValidateRange(1, 6)]
    [int]$SprintWeeks = 2,

    [ValidateRange(7, 365)]
    [int]$RetentionDays = 30,

    [ValidateSet('month', 'sprint')]
    [string]$GroupBy = 'month',

    [ValidateNotNullOrEmpty()]
    [string]$RecordLanguage = 'Italian',

    [switch]$DisableSprints,
    [switch]$DisableCompaction,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,
        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($LiteralPath, $Content, $encoding)
}

$resolvedRoot = [System.IO.Path]::GetFullPath($ContextRoot)
$userProfileRoot = [Environment]::GetFolderPath('UserProfile')
if ([string]::IsNullOrWhiteSpace($userProfileRoot)) {
    throw 'Cannot resolve the user profile directory.'
}

if ([string]::IsNullOrWhiteSpace($env:XDG_CONFIG_HOME)) {
    $platformConfigRoot = Join-Path $userProfileRoot '.config'
} else {
    $platformConfigRoot = [System.IO.Path]::GetFullPath($env:XDG_CONFIG_HOME)
}

$pointerDirectory = Join-Path $platformConfigRoot 'skill-workflow-management'
$pointerFile = Join-Path $pointerDirectory 'context-path.json'
$configurationFile = Join-Path $resolvedRoot '.workflow-config.json'

if ((Test-Path -LiteralPath $configurationFile -PathType Leaf) -and -not $Force) {
    throw "Configuration already exists: $configurationFile. Use -Force to replace it."
}

if ((Test-Path -LiteralPath $pointerFile -PathType Leaf) -and -not $Force) {
    $existingPointer = Get-Content -Raw -LiteralPath $pointerFile | ConvertFrom-Json
    $existingRoot = [System.IO.Path]::GetFullPath([string]$existingPointer.ai_context_root)
    if (-not $existingRoot.Equals($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Context pointer already targets $existingRoot. Use -Force to replace it."
    }
}

$directories = @(
    $resolvedRoot,
    (Join-Path $resolvedRoot 'sessions\archive'),
    (Join-Path $resolvedRoot 'sprints'),
    (Join-Path $resolvedRoot 'tasks\todo'),
    (Join-Path $resolvedRoot 'tasks\done'),
    (Join-Path $resolvedRoot 'focus'),
    (Join-Path $resolvedRoot 'roadmap'),
    (Join-Path $resolvedRoot 'meetings'),
    $pointerDirectory
)

foreach ($directory in $directories) {
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
}

$configuration = [ordered]@{
    version = '1.2.0'
    ai_context_root = $resolvedRoot
    record_language = $RecordLanguage
    sprint = [ordered]@{
        enabled = -not $DisableSprints.IsPresent
        duration_weeks = $SprintWeeks
    }
    compaction = [ordered]@{
        enabled = -not $DisableCompaction.IsPresent
        retention_days = $RetentionDays
        group_by = $GroupBy
    }
}

$pointer = [ordered]@{
    ai_context_root = $resolvedRoot
}

$configurationJson = ($configuration | ConvertTo-Json -Depth 4) + [Environment]::NewLine
$pointerJson = ($pointer | ConvertTo-Json -Depth 2) + [Environment]::NewLine
Write-Utf8NoBom -LiteralPath $configurationFile -Content $configurationJson
Write-Utf8NoBom -LiteralPath $pointerFile -Content $pointerJson

Write-Output "Configuration saved: $configurationFile"
Write-Output "Context pointer saved: $pointerFile"
Write-Output 'Directory structure ensured.'
Write-Output 'Operational Markdown records will be created when the first session starts.'
