# create-project-understanding.ps1 - Create a new Project Understanding document deterministically
#
# This script ONLY:
#   1. Creates the correct directory structure (.specify/)
#   2. Copies the template with {{PLACEHOLDERS}} intact
#   3. Returns metadata (path, template) for AI to fill in
#
# The calling AI agent is responsible for filling {{PLACEHOLDERS}}
#
# Usage:
#   scripts/powershell/create-project-understanding.ps1 [-Json]

param(
    [switch]$Json
)

$ErrorActionPreference = "Stop"

# Get repository root
$repoRoot = if (Test-Path ".git") {
    (git rev-parse --show-toplevel 2>$null) -or $PWD
} else {
    $PWD
}

$specifyDir = Join-Path $repoRoot ".specify"
if (-not (Test-Path $specifyDir)) {
    New-Item -ItemType Directory -Path $specifyDir -Force | Out-Null
}

# Check for template (try both locations)
$templatePath = $null
$template1 = Join-Path $specifyDir "templates\understand-template.md"
$template2 = Join-Path $repoRoot "templates\understand-template.md"

if (Test-Path $template1) {
    $templatePath = $template1
} elseif (Test-Path $template2) {
    $templatePath = $template2
} else {
    Write-Error "Error: understand-template.md not found at .specify/templates/ or templates/"
    exit 1
}

$outFile = Join-Path $specifyDir "project-understanding.md"

# Simply copy the template (AI will fill placeholders)
Copy-Item -Path $templatePath -Destination $outFile -Force

$absPath = (Resolve-Path $outFile).Path
if ($Json) {
    $templateName = Split-Path -Leaf $templatePath
    $result = @{
        path = $absPath
        template = $templateName
    } | ConvertTo-Json -Compress
    Write-Output $result
} else {
    Write-Host "✅ Project Understanding template copied → $absPath"
    Write-Host "Note: AI agent should now fill in {{PLACEHOLDERS}}"
}

