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
    $packageRoot = Join-Path $repositoryRoot 'packages\codex\workflow-management'
    @(
        'CORE.md', 'SKILL.md', 'conventions.md', 'setup-skills.ps1',
        'setup-skills.sh', 'compact-sessions.sh', 'agents\openai.yaml',
        'references\sessions.md', 'references\tasks.md',
        'references\planning-and-notes.md', 'references\steering.md',
        'references\tracking.md', 'references\bootstrap.md',
        'references\recap-maintenance.md', 'references\setup-guided.md',
        'references\compaction.md'
    ) | ForEach-Object {
        Assert-Condition (Test-Path -LiteralPath (Join-Path $packageRoot $_) -PathType Leaf) "Missing package file: $_"
    }

    @(
        'CORE.md', 'conventions.md', 'setup-skills.ps1', 'setup-skills.sh',
        'compact-sessions.sh', 'references\sessions.md',
        'references\tasks.md', 'references\planning-and-notes.md',
        'references\steering.md', 'references\tracking.md',
        'references\bootstrap.md',
        'references\recap-maintenance.md',
        'references\setup-guided.md',
        'references\compaction.md',
        'examples\basic-ai-context\README.md',
        'examples\basic-ai-context\RECAP.md',
        'examples\basic-ai-context\tasks\INDEX.md'
    ) | ForEach-Object {
        $rootContent = Get-Content -Raw -LiteralPath (Join-Path $repositoryRoot $_)
        $packageContent = Get-Content -Raw -LiteralPath (Join-Path $packageRoot $_)
        Assert-Condition ($rootContent -ceq $packageContent) "Package file differs from root: $_"
    }

    Assert-Condition (-not (Test-Path -LiteralPath (Join-Path $repositoryRoot 'examples\basic-ai-context\LAST_SESSION.md'))) 'Root starter contains LAST_SESSION.md.'
    Assert-Condition (-not (Test-Path -LiteralPath (Join-Path $packageRoot 'examples\basic-ai-context\LAST_SESSION.md'))) 'Package starter contains LAST_SESSION.md.'

    # The repository root is the Claude Code skill; there is no adapters/ tree.
    Assert-Condition (-not (Test-Path -LiteralPath (Join-Path $repositoryRoot 'adapters'))) 'Repository still contains an adapters/ tree.'
    $rootSkill = Get-Content -Raw -LiteralPath (Join-Path $repositoryRoot 'SKILL.md')
    Assert-Condition ($rootSkill -match '(?m)^name: workflow-management\s*$') 'Root SKILL.md is not the workflow-management skill.'

    $openAiMetadata = Get-Content -Raw -LiteralPath (Join-Path $packageRoot 'agents\openai.yaml')
    Assert-Condition ($openAiMetadata.Contains('$workflow-management')) 'Default prompt does not reference $workflow-management.'

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
    Assert-Condition ([string]$configuration.record_language -eq 'English') 'Record language should default to English.'

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

    & (Join-Path $repositoryRoot 'setup-skills.ps1') -ContextRoot $contextRoot -RecordLanguage Italian -Force
    $updatedConfiguration = Get-Content -Raw -LiteralPath $configurationFile | ConvertFrom-Json
    Assert-Condition ([string]$updatedConfiguration.record_language -eq 'Italian') 'Setup did not persist the configured record language.'

    # -Here scaffolds a per-project context without reading or writing the pointer.
    $hereConfigRoot = Join-Path $testRoot 'here-xdg'
    $hereContext = Join-Path $testRoot 'ai_context_project'
    $env:XDG_CONFIG_HOME = $hereConfigRoot
    $hereOutput = & (Join-Path $repositoryRoot 'setup-skills.ps1') -ContextRoot $hereContext -Here | Out-String
    Assert-Condition (Test-Path -LiteralPath (Join-Path $hereContext '.workflow-config.json') -PathType Leaf) '-Here did not create the configuration.'
    Assert-Condition (Test-Path -LiteralPath (Join-Path $hereContext 'sessions\archive') -PathType Container) '-Here did not create the layout.'
    Assert-Condition (-not (Test-Path -LiteralPath $hereConfigRoot)) '-Here created the pointer directory.'
    Assert-Condition ($hereOutput.Contains('"folders"')) '-Here did not print the workspace snippet.'
    Assert-Condition ($hereOutput.Contains($hereContext)) '-Here snippet omits the context path.'

    Write-Output 'PowerShell smoke tests passed'
} finally {
    $env:XDG_CONFIG_HOME = $previousConfigRoot
    $resolvedTestRoot = [System.IO.Path]::GetFullPath($testRoot)
    if ($resolvedTestRoot.StartsWith($temporaryBase, [System.StringComparison]::OrdinalIgnoreCase) -and
        (Test-Path -LiteralPath $resolvedTestRoot -PathType Container)) {
        Remove-Item -LiteralPath $resolvedTestRoot -Recurse -Force
    }
}
