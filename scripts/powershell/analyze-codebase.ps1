#!/usr/bin/env pwsh
# analyze-codebase.ps1
# Analyze existing codebase to extract technology stack, structure, and patterns
# Usage: analyze-codebase.ps1 [-Json]

[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

# Show help if requested
if ($Help) {
    Write-Output "Usage: ./analyze-codebase.ps1 [-Json] [-Help]"
    Write-Output "  -Json     Output results in JSON format"
    Write-Output "  -Help     Show this help message"
    exit 0
}

# Load common functions
. "$PSScriptRoot/common.ps1"

# Get repository root
$repoRoot = Get-RepoRoot
Set-Location $repoRoot

# Initialize analysis results
$techStack = @{
    LANGUAGE = ""
    FRAMEWORKS = ""
    DATABASE = ""
}
$buildTools = ""
$testFrameworks = ""
$projectStructure = ""
$directoryStructure = ""

# Function to detect language from files
function Get-Language {
    $lang = @()
    
    # Check for package.json (Node.js/JavaScript/TypeScript)
    if (Test-Path "package.json") {
        $tsFiles = Get-ChildItem -Path . -Recurse -Depth 3 -Include *.ts,*.tsx -ErrorAction SilentlyContinue
        if ($tsFiles) {
            $lang += "TypeScript"
        } else {
            $lang += "JavaScript"
        }
    }
    
    # Check for Python files
    if ((Test-Path "requirements.txt") -or (Test-Path "pyproject.toml") -or (Test-Path "setup.py")) {
        $lang += "Python"
    }
    
    # Check for Rust
    if (Test-Path "Cargo.toml") {
        $lang += "Rust"
    }
    
    # Check for Go
    if (Test-Path "go.mod") {
        $lang += "Go"
    }
    
    # Check for Java
    if ((Test-Path "pom.xml") -or (Test-Path "build.gradle")) {
        $lang += "Java"
    }
    
    # Check for C#
    $csprojFiles = Get-ChildItem -Path . -Recurse -Depth 2 -Include *.csproj,*.sln -ErrorAction SilentlyContinue
    if ($csprojFiles) {
        $lang += "C#"
    }
    
    # Check for Ruby
    if (Test-Path "Gemfile") {
        $lang += "Ruby"
    }
    
    # Check for PHP
    if (Test-Path "composer.json") {
        $lang += "PHP"
    }
    
    return ($lang -join ", ")
}

# Function to detect frameworks
function Get-Frameworks {
    $frameworks = @()
    
    # Check package.json for frameworks
    if (Test-Path "package.json") {
        $packageJson = Get-Content "package.json" -Raw | ConvertFrom-Json
        if ($packageJson.dependencies -or $packageJson.devDependencies) {
            $deps = @{}
            if ($packageJson.dependencies) {
                $packageJson.dependencies.PSObject.Properties | ForEach-Object { $deps[$_.Name] = $_.Value }
            }
            if ($packageJson.devDependencies) {
                $packageJson.devDependencies.PSObject.Properties | ForEach-Object { $deps[$_.Name] = $_.Value }
            }
            
            if ($deps.ContainsKey("react")) { $frameworks += "React" }
            if ($deps.ContainsKey("vue")) { $frameworks += "Vue" }
            if ($deps.ContainsKey("@angular/core")) { $frameworks += "Angular" }
            if ($deps.ContainsKey("express")) { $frameworks += "Express" }
            if ($deps.ContainsKey("next")) { $frameworks += "Next.js" }
        }
    }
    
    # Check Python files for frameworks
    if (Test-Path "requirements.txt") {
        $content = Get-Content "requirements.txt" -Raw
        if ($content -match "django") { $frameworks += "Django" }
        if ($content -match "flask") { $frameworks += "Flask" }
        if ($content -match "fastapi") { $frameworks += "FastAPI" }
    }
    
    # Check for Rust frameworks
    if (Test-Path "Cargo.toml") {
        $content = Get-Content "Cargo.toml" -Raw
        if ($content -match "actix") { $frameworks += "Actix" }
        if ($content -match "rocket") { $frameworks += "Rocket" }
    }
    
    return ($frameworks -join ", ")
}

# Function to detect build tools
function Get-BuildTools {
    $tools = @()
    
    if (Test-Path "package.json") { $tools += "npm/yarn/pnpm" }
    if (Test-Path "requirements.txt") { $tools += "pip" }
    if (Test-Path "pyproject.toml") { $tools += "poetry/pip" }
    if (Test-Path "Cargo.toml") { $tools += "cargo" }
    if (Test-Path "go.mod") { $tools += "go" }
    if (Test-Path "pom.xml") { $tools += "maven" }
    if (Test-Path "build.gradle") { $tools += "gradle" }
    if (Test-Path "Gemfile") { $tools += "bundler" }
    if (Test-Path "composer.json") { $tools += "composer" }
    
    return ($tools -join ", ")
}

# Function to detect test frameworks
function Get-TestFrameworks {
    $frameworks = @()
    
    if (Test-Path "package.json") {
        $packageJson = Get-Content "package.json" -Raw | ConvertFrom-Json
        $deps = @{}
        if ($packageJson.dependencies) {
            $packageJson.dependencies.PSObject.Properties | ForEach-Object { $deps[$_.Name] = $_.Value }
        }
        if ($packageJson.devDependencies) {
            $packageJson.devDependencies.PSObject.Properties | ForEach-Object { $deps[$_.Name] = $_.Value }
        }
        
        if ($deps.ContainsKey("jest")) { $frameworks += "Jest" }
        if ($deps.ContainsKey("mocha")) { $frameworks += "Mocha" }
        if ($deps.ContainsKey("vitest")) { $frameworks += "Vitest" }
    }
    
    if (Test-Path "requirements.txt") {
        $content = Get-Content "requirements.txt" -Raw
        if ($content -match "pytest") { $frameworks += "pytest" }
        if ($content -match "unittest") { $frameworks += "unittest" }
    }
    
    if (Test-Path "Cargo.toml") { $frameworks += "cargo test" }
    
    return ($frameworks -join ", ")
}

# Function to detect database
function Get-Database {
    $db = ""
    
    if (Test-Path "package.json") {
        $packageJson = Get-Content "package.json" -Raw | ConvertFrom-Json
        $deps = @{}
        if ($packageJson.dependencies) {
            $packageJson.dependencies.PSObject.Properties | ForEach-Object { $deps[$_.Name] = $_.Value }
        }
        if ($packageJson.devDependencies) {
            $packageJson.devDependencies.PSObject.Properties | ForEach-Object { $deps[$_.Name] = $_.Value }
        }
        
        if ($deps.ContainsKey("pg")) { $db = "PostgreSQL" }
        if ($deps.ContainsKey("mysql2")) { $db = "MySQL" }
        if ($deps.ContainsKey("mongodb")) { $db = "MongoDB" }
        if ($deps.ContainsKey("sqlite3")) { $db = "SQLite" }
    }
    
    if (Test-Path "requirements.txt") {
        $content = Get-Content "requirements.txt" -Raw
        if ($content -match "psycopg2|postgresql") { $db = "PostgreSQL" }
        if ($content -match "mysql|pymysql") { $db = "MySQL" }
        if ($content -match "pymongo|motor") { $db = "MongoDB" }
        if ($content -match "sqlite") { $db = "SQLite" }
    }
    
    return $db
}

# Function to detect project structure
function Get-ProjectStructure {
    if ((Test-Path "frontend") -and (Test-Path "backend")) {
        return "Web application (frontend + backend)"
    }
    elseif ((Test-Path "client") -and (Test-Path "server")) {
        return "Web application (client + server)"
    }
    elseif ((Test-Path "ios") -or (Test-Path "android")) {
        return "Mobile application"
    }
    elseif ((Test-Path "packages") -or (Test-Path "apps")) {
        return "Monorepo"
    }
    elseif ((Test-Path "src") -or (Test-Path "lib") -or (Test-Path "app")) {
        return "Single project"
    }
    else {
        return "Custom structure"
    }
}

# Function to get top-level directory structure
function Get-DirectoryStructure {
    $maxDepth = 2
    Get-ChildItem -Path . -Directory -Depth $maxDepth -Exclude .git,.specify,node_modules | 
        Where-Object { $_.FullName -notmatch '\\\.' } |
        Select-Object -First 20 -ExpandProperty FullName |
        ForEach-Object { $_.Replace($repoRoot, "").TrimStart('\') }
}

# Perform analysis
$techStack.LANGUAGE = Get-Language
$techStack.FRAMEWORKS = Get-Frameworks
$techStack.DATABASE = Get-Database
$buildTools = Get-BuildTools
$testFrameworks = Get-TestFrameworks
$projectStructure = Get-ProjectStructure
$dirStructure = Get-DirectoryStructure

# Output results
if ($Json) {
    $result = [PSCustomObject]@{
        TECH_STACK = [PSCustomObject]@{
            LANGUAGE = $techStack.LANGUAGE
            FRAMEWORKS = $techStack.FRAMEWORKS
            DATABASE = $techStack.DATABASE
        }
        BUILD_TOOLS = $buildTools
        TEST_FRAMEWORKS = $testFrameworks
        PROJECT_STRUCTURE = $projectStructure
        DIRECTORY_STRUCTURE = ($dirStructure -join "`n")
        REPO_ROOT = $repoRoot
    }
    $result | ConvertTo-Json -Compress -Depth 10
} else {
    Write-Output "TECH_STACK:"
    Write-Output "  LANGUAGE: $($techStack.LANGUAGE)"
    Write-Output "  FRAMEWORKS: $($techStack.FRAMEWORKS)"
    Write-Output "  DATABASE: $($techStack.DATABASE)"
    Write-Output "BUILD_TOOLS: $buildTools"
    Write-Output "TEST_FRAMEWORKS: $testFrameworks"
    Write-Output "PROJECT_STRUCTURE: $projectStructure"
    Write-Output "DIRECTORY_STRUCTURE:"
    $dirStructure | ForEach-Object { Write-Output "  $_" }
    Write-Output "REPO_ROOT: $repoRoot"
}

