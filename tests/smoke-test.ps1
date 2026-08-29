Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$temporaryBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$testRoot = Join-Path $temporaryBase ("workflow-management-smoke-{0}" -f [guid]::NewGuid())
$contextRoot = Join-Path $testRoot 'ai-context'
$testConfigRoot = Join-Path $testRoot 'xdg-config'
$previousConfigRoot = $env:XDG_CONFIG_HOME

function Assert-Condition {
    param(
        [Parameter(Mandatory = $true)]
        [bool]$Condition,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

try {
    $env:XDG_CONFIG_HOME = $testConfigRoot
    & (Join-Path $repositoryRoot 'setup-skills.ps1') -ContextRoot $contextRoot

    $configurationFile = Join-Path $contextRoot '.workflow-config.json'
    $pointerFile = Join-Path $testConfigRoot 'skill-workflow-management\context-path.json'
    Assert-Condition (Test-Path -LiteralPath $configurationFile -PathType Leaf) 'Configuration was not created.'
    Assert-Condition (Test-Path -LiteralPath $pointerFile -PathType Leaf) 'Context pointer was not created.'

    $configuration = Get-Content -Raw -LiteralPath $configurationFile | ConvertFrom-Json
    $pointer = Get-Content -Raw -LiteralPath $pointerFile | ConvertFrom-Json
    $resolvedContext = [System.IO.Path]::GetFullPath($contextRoot)
    Assert-Condition ([System.IO.Path]::GetFullPath([string]$configuration.ai_context_root) -eq $resolvedContext) 'Configuration root is incorrect.'
    Assert-Condition ([System.IO.Path]::GetFullPath([string]$pointer.ai_context_root) -eq $resolvedContext) 'Pointer root is incorrect.'
    Assert-Condition ([bool]$configuration.sprint.enabled) 'Sprints should be enabled by default.'
    Assert-Condition ([bool]$configuration.compaction.enabled) 'Compaction should be enabled by default.'

    @(
        'sessions\archive', 'sprints', 'tasks\todo', 'tasks\done',
        'focus', 'roadmap', 'meetings'
    ) | ForEach-Object {
        Assert-Condition (Test-Path -LiteralPath (Join-Path $contextRoot $_) -PathType Container) "Missing directory: $_"
    }

    @('RECAP.md', 'LAST_SESSION.md', 'tasks\INDEX.md') | ForEach-Object {
        Assert-Condition (-not (Test-Path -LiteralPath (Join-Path $contextRoot $_))) "Setup created operational record unexpectedly: $_"
    }

    $secondRunFailed = $false
    try {
        & (Join-Path $repositoryRoot 'setup-skills.ps1') -ContextRoot $contextRoot
    } catch {
        $secondRunFailed = $true
    }
    Assert-Condition $secondRunFailed 'Setup replaced an existing configuration without -Force.'

    Write-Output 'PowerShell smoke tests passed'
} finally {
    $env:XDG_CONFIG_HOME = $previousConfigRoot
    $resolvedTestRoot = [System.IO.Path]::GetFullPath($testRoot)
    if ($resolvedTestRoot.StartsWith($temporaryBase, [System.StringComparison]::OrdinalIgnoreCase) -and
        (Test-Path -LiteralPath $resolvedTestRoot -PathType Container)) {
        Remove-Item -LiteralPath $resolvedTestRoot -Recurse -Force
    }
}
