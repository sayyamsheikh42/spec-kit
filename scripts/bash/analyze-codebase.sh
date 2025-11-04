#!/usr/bin/env bash

set -e

# analyze-codebase.sh
# Analyze existing codebase to extract technology stack, structure, and patterns
# Usage: analyze-codebase.sh [--json]

# Parse command line arguments
JSON_MODE=false

for arg in "$@"; do
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
        --help|-h)
            cat << 'EOF'
Usage: analyze-codebase.sh [OPTIONS]

Analyze existing codebase to extract technology stack and structure.

OPTIONS:
  --json              Output in JSON format
  --help, -h          Show this help message

EOF
            exit 0
            ;;
        *)
            echo "ERROR: Unknown option '$arg'. Use --help for usage information." >&2
            exit 1
            ;;
    esac
done

# Get script directory and load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Get repository root
REPO_ROOT=$(get_repo_root)
cd "$REPO_ROOT"

# Initialize analysis results
declare -A TECH_STACK
declare -A BUILD_TOOLS
declare -A DEPENDENCIES
PROJECT_STRUCTURE=""
PATTERNS=""
PRIMARY_LANGUAGE=""
PROJECT_TYPE=""

# Function to detect language from files
detect_language() {
    local lang=""
    
    # Check for package.json (Node.js/JavaScript/TypeScript)
    if [[ -f "package.json" ]]; then
        if find . -maxdepth 3 -name "*.ts" -o -name "*.tsx" 2>/dev/null | grep -q .; then
            lang="TypeScript"
        else
            lang="JavaScript"
        fi
    fi
    
    # Check for Python files
    if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
        if [[ -n "$lang" ]]; then
            lang="$lang, Python"
        else
            lang="Python"
        fi
    fi
    
    # Check for Rust
    if [[ -f "Cargo.toml" ]]; then
        if [[ -n "$lang" ]]; then
            lang="$lang, Rust"
        else
            lang="Rust"
        fi
    fi
    
    # Check for Go
    if [[ -f "go.mod" ]]; then
        if [[ -n "$lang" ]]; then
            lang="$lang, Go"
        else
            lang="Go"
        fi
    fi
    
    # Check for Java
    if [[ -f "pom.xml" ]] || [[ -f "build.gradle" ]]; then
        if [[ -n "$lang" ]]; then
            lang="$lang, Java"
        else
            lang="Java"
        fi
    fi
    
    # Check for C#
    if find . -maxdepth 2 -name "*.csproj" -o -name "*.sln" 2>/dev/null | grep -q .; then
        if [[ -n "$lang" ]]; then
            lang="$lang, C#"
        else
            lang="C#"
        fi
    fi
    
    # Check for Ruby
    if [[ -f "Gemfile" ]]; then
        if [[ -n "$lang" ]]; then
            lang="$lang, Ruby"
        else
            lang="Ruby"
        fi
    fi
    
    # Check for PHP
    if [[ -f "composer.json" ]]; then
        if [[ -n "$lang" ]]; then
            lang="$lang, PHP"
        else
            lang="PHP"
        fi
    fi
    
    echo "$lang"
}

# Function to detect frameworks
detect_frameworks() {
    local frameworks=()
    
    # Check package.json for frameworks
    if [[ -f "package.json" ]]; then
        if grep -q '"react"' package.json 2>/dev/null; then
            frameworks+=("React")
        fi
        if grep -q '"vue"' package.json 2>/dev/null; then
            frameworks+=("Vue")
        fi
        if grep -q '"@angular"' package.json 2>/dev/null; then
            frameworks+=("Angular")
        fi
        if grep -q '"express"' package.json 2>/dev/null; then
            frameworks+=("Express")
        fi
        if grep -q '"next"' package.json 2>/dev/null; then
            frameworks+=("Next.js")
        fi
    fi
    
    # Check Python files for frameworks
    if [[ -f "requirements.txt" ]]; then
        if grep -qi "django" requirements.txt 2>/dev/null; then
            frameworks+=("Django")
        fi
        if grep -qi "flask" requirements.txt 2>/dev/null; then
            frameworks+=("Flask")
        fi
        if grep -qi "fastapi" requirements.txt 2>/dev/null; then
            frameworks+=("FastAPI")
        fi
    fi
    
    # Check for Rust frameworks
    if [[ -f "Cargo.toml" ]]; then
        if grep -q "actix" Cargo.toml 2>/dev/null; then
            frameworks+=("Actix")
        fi
        if grep -q "rocket" Cargo.toml 2>/dev/null; then
            frameworks+=("Rocket")
        fi
    fi
    
    IFS=','
    echo "${frameworks[*]}"
    unset IFS
}

# Function to detect build tools
detect_build_tools() {
    local tools=()
    
    [[ -f "package.json" ]] && tools+=("npm/yarn/pnpm")
    [[ -f "requirements.txt" ]] && tools+=("pip")
    [[ -f "pyproject.toml" ]] && tools+=("poetry/pip")
    [[ -f "Cargo.toml" ]] && tools+=("cargo")
    [[ -f "go.mod" ]] && tools+=("go")
    [[ -f "pom.xml" ]] && tools+=("maven")
    [[ -f "build.gradle" ]] && tools+=("gradle")
    [[ -f "Gemfile" ]] && tools+=("bundler")
    [[ -f "composer.json" ]] && tools+=("composer")
    
    IFS=','
    echo "${tools[*]}"
    unset IFS
}

# Function to detect test frameworks
detect_test_frameworks() {
    local frameworks=()
    
    [[ -f "package.json" ]] && {
        grep -q '"jest"' package.json 2>/dev/null && frameworks+=("Jest")
        grep -q '"mocha"' package.json 2>/dev/null && frameworks+=("Mocha")
        grep -q '"vitest"' package.json 2>/dev/null && frameworks+=("Vitest")
    }
    
    [[ -f "requirements.txt" ]] && {
        grep -qi "pytest" requirements.txt 2>/dev/null && frameworks+=("pytest")
        grep -qi "unittest" requirements.txt 2>/dev/null && frameworks+=("unittest")
    }
    
    [[ -f "Cargo.toml" ]] && frameworks+=("cargo test")
    
    IFS=','
    echo "${frameworks[*]}"
    unset IFS
}

# Function to detect database
detect_database() {
    local db=""
    
    if [[ -f "package.json" ]]; then
        grep -q '"pg"' package.json 2>/dev/null && db="PostgreSQL"
        grep -q '"mysql2"' package.json 2>/dev/null && db="MySQL"
        grep -q '"mongodb"' package.json 2>/dev/null && db="MongoDB"
        grep -q '"sqlite3"' package.json 2>/dev/null && db="SQLite"
    fi
    
    if [[ -f "requirements.txt" ]]; then
        grep -qi "psycopg2\|postgresql" requirements.txt 2>/dev/null && db="PostgreSQL"
        grep -qi "mysql\|pymysql" requirements.txt 2>/dev/null && db="MySQL"
        grep -qi "pymongo\|motor" requirements.txt 2>/dev/null && db="MongoDB"
        grep -qi "sqlite" requirements.txt 2>/dev/null && db="SQLite"
    fi
    
    echo "$db"
}

# Function to detect project structure
detect_project_structure() {
    local structure=""
    
    if [[ -d "frontend" ]] && [[ -d "backend" ]]; then
        structure="Web application (frontend + backend)"
    elif [[ -d "client" ]] && [[ -d "server" ]]; then
        structure="Web application (client + server)"
    elif [[ -d "ios" ]] || [[ -d "android" ]]; then
        structure="Mobile application"
    elif [[ -d "packages" ]] || [[ -d "apps" ]]; then
        structure="Monorepo"
    elif [[ -d "src" ]] || [[ -d "lib" ]] || [[ -d "app" ]]; then
        structure="Single project"
    else
        structure="Custom structure"
    fi
    
    echo "$structure"
}

# Function to get top-level directory structure
get_directory_structure() {
    local max_depth=2
    find . -maxdepth $max_depth -type d ! -path '*/\.*' ! -path '*/node_modules/*' ! -path '*/\.git/*' | \
        sort | \
        sed "s|^\./||" | \
        sed "s|^\.$|ROOT|" | \
        head -20
}

# Perform analysis
PRIMARY_LANGUAGE=$(detect_language)
FRAMEWORKS=$(detect_frameworks)
BUILD_TOOLS_STR=$(detect_build_tools)
TEST_FRAMEWORKS=$(detect_test_frameworks)
DATABASE=$(detect_database)
PROJECT_STRUCTURE=$(detect_project_structure)
DIR_STRUCTURE=$(get_directory_structure)

# Build JSON output
if $JSON_MODE; then
    # Escape newlines and special characters for JSON
    dir_structure_json=$(echo "$DIR_STRUCTURE" | sed ':a;N;$!ba;s/\n/\\n/g' | sed 's/"/\\"/g')
    
    cat <<EOF
{
  "TECH_STACK": {
    "LANGUAGE": "$PRIMARY_LANGUAGE",
    "FRAMEWORKS": "$FRAMEWORKS",
    "DATABASE": "$DATABASE"
  },
  "BUILD_TOOLS": "$BUILD_TOOLS_STR",
  "TEST_FRAMEWORKS": "$TEST_FRAMEWORKS",
  "PROJECT_STRUCTURE": "$PROJECT_STRUCTURE",
  "DIRECTORY_STRUCTURE": "$dir_structure_json",
  "REPO_ROOT": "$REPO_ROOT"
}
EOF
else
    # Text output
    echo "TECH_STACK:"
    echo "  LANGUAGE: $PRIMARY_LANGUAGE"
    echo "  FRAMEWORKS: $FRAMEWORKS"
    echo "  DATABASE: $DATABASE"
    echo "BUILD_TOOLS: $BUILD_TOOLS_STR"
    echo "TEST_FRAMEWORKS: $TEST_FRAMEWORKS"
    echo "PROJECT_STRUCTURE: $PROJECT_STRUCTURE"
    echo "DIRECTORY_STRUCTURE:"
    echo "$DIR_STRUCTURE" | while IFS= read -r line; do
        echo "  $line"
    done
    echo "REPO_ROOT: $REPO_ROOT"
fi

