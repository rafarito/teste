#!/usr/bin/env pwsh
# Create a new feature
[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$AllowExistingBranch,
    [switch]$DryRun,
    [string]$ShortName,
    [Parameter()]
    [long]$Number = 0,
    [switch]$Timestamp,
    [switch]$Help,
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$FeatureDescription
)
$ErrorActionPreference = 'Stop'

# Show help if requested
if ($Help) {
    Write-Host "Usage: ./create-new-feature.ps1 [-Json] [-DryRun] [-AllowExistingBranch] [-ShortName <name>] [-Number N] [-Timestamp] <feature description>"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Json               Output in JSON format"
    Write-Host "  -DryRun             Compute feature name and paths without creating directories or files"
    Write-Host "  -AllowExistingBranch  Reuse an existing feature directory if it already exists"
    Write-Host "  -ShortName <name>   Provide a custom short name (2-4 words) for the feature"
    Write-Host "  -Number N           Specify branch number manually (overrides auto-detection)"
    Write-Host "  -Timestamp          Use timestamp prefix (YYYYMMDD-HHMMSS) instead of sequential numbering"
    Write-Host "  -Help               Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  ./create-new-feature.ps1 'Add user authentication system' -ShortName 'user-auth'"
    Write-Host "  ./create-new-feature.ps1 'Implement OAuth2 integration for API'"
    Write-Host "  ./create-new-feature.ps1 -Timestamp -ShortName 'user-auth' 'Add user authentication'"
    exit 0
}

# Check if feature description provided
if (-not $FeatureDescription -or $FeatureDescription.Count -eq 0) {
    Write-Error "Usage: ./create-new-feature.ps1 [-Json] [-DryRun] [-AllowExistingBranch] [-ShortName <name>] [-Number N] [-Timestamp] <feature description>"
    exit 1
}

$featureDesc = ($FeatureDescription -join ' ').Trim()

# Validate description is not empty after trimming (e.g., user passed only whitespace)
if ([string]::IsNullOrWhiteSpace($featureDesc)) {
    Write-Error "Error: Feature description cannot be empty or contain only whitespace"
    exit 1
}

function Get-HighestNumberFromSpecs {
    param([string]$SpecsDir)

    [long]$highest = 0
    if (Test-Path $SpecsDir) {
        Get-ChildItem -Path $SpecsDir -Directory | ForEach-Object {
            # Match sequential prefixes (>=3 digits), but skip timestamp dirs.
            if ($_.Name -match '^(\d{3,})-' -and $_.Name -notmatch '^\d{8}-\d{6}-') {
                [long]$num = 0
                if ([long]::TryParse($matches[1], [ref]$num) -and $num -gt $highest) {
                    $highest = $num
                }
            }
        }
    }
    return $highest
}

function ConvertTo-CleanBranchName {
    param([string]$Name)

    return $Name.ToLower() -replace '[^a-z0-9]', '-' -replace '-{2,}', '-' -replace '^-', '' -replace '-$', ''
}
# Load common functions (includes Get-RepoRoot and Resolve-Template)
. "$PSScriptRoot/common.ps1"

# Use common.ps1 functions which prioritize .specify
$repoRoot = Get-RepoRoot

Set-Location $repoRoot

$specsDir = Join-Path $repoRoot 'specs'
if (-not $DryRun) {
    New-Item -ItemType Directory -Path $specsDir -Force | Out-Null
}

# Function to generate branch name with stop word filtering and length filtering
function Get-BranchName {
    param([string]$Description)

    # Common stop words to filter out — English AND Portuguese (this tool's
    # feature descriptions are routinely written in pt-BR, e.g. "Gere a
    # funcionalidade de X" or "Crie a tela de Y"). Without the Portuguese
    # half, none of these get filtered — "gere"/"crie"/"funcionalidade" survive
    # as "meaningful" words and can crowd out the actual subject of the
    # feature (only the first 3-4 meaningful words become the branch suffix).
    $stopWords = @(
        'i', 'a', 'an', 'the', 'to', 'for', 'of', 'in', 'on', 'at', 'by', 'with', 'from',
        'is', 'are', 'was', 'were', 'be', 'been', 'being', 'have', 'has', 'had',
        'do', 'does', 'did', 'will', 'would', 'should', 'could', 'can', 'may', 'might', 'must', 'shall',
        'this', 'that', 'these', 'those', 'my', 'your', 'our', 'their',
        'want', 'need', 'add', 'get', 'set',
        'de', 'da', 'do', 'das', 'dos', 'em', 'no', 'na', 'nos', 'nas', 'um', 'uma', 'uns', 'umas',
        'para', 'por', 'com', 'sem', 'sobre', 'entre', 'ate', 'e', 'ou', 'que', 'se', 'nao',
        'gere', 'gerar', 'crie', 'criar', 'adicione', 'adicionar', 'implemente', 'implementar',
        'faca', 'fazer', 'quero', 'preciso', 'sistema', 'funcionalidade', 'funcao', 'tela', 'feature'
    )

    # Normalize accented characters (á->a, ç->c, ã->a, etc.) BEFORE stripping
    # non-alphanumerics — without this, the regex below (ASCII a-z0-9 only)
    # treats each accented letter as punctuation and replaces it with a space,
    # splitting one word into unrelated fragments (e.g. "multiplicação"
    # becomes the tokens "multiplica" and "o", "divisão" becomes "divis" and
    # "o" — neither resembles the real word anymore, and the short leftover
    # fragments then get caught by the acronym-detection bug below too).
    $normalized = $Description.Normalize([System.Text.NormalizationForm]::FormD)
    $noDiacritics = -join ($normalized.ToCharArray() | Where-Object {
        [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark
    })

    # Convert to lowercase and extract words (alphanumeric only)
    $cleanName = $noDiacritics.ToLower() -replace '[^a-z0-9\s]', ' '
    $words = $cleanName -split '\s+' | Where-Object { $_ }

    # Filter words: remove stop words and words shorter than 3 chars (unless they're uppercase acronyms in original)
    $meaningfulWords = @()
    foreach ($word in $words) {
        # Skip stop words
        if ($stopWords -contains $word) { continue }

        # Keep words that are length >= 3 OR appear as uppercase in original (likely acronyms)
        if ($word.Length -ge 3) {
            $meaningfulWords += $word
        } elseif ($Description -cmatch "\b$($word.ToUpper())\b") {
            # -cmatch (case-SENSITIVE): a lowercase 1-2 char word like "de" or
            # "e" always "matches" its own uppercase form with the default
            # case-insensitive -match (since the word obviously appears in the
            # text in some case) — that silently defeated this whole length
            # filter for every short word, not just real acronyms. -cmatch
            # only keeps it when the original text actually spelled it in
            # ALL CAPS (a genuine acronym like "API"/"CRUD"), which is the
            # intent this branch documents.
            $meaningfulWords += $word
        }
    }

    # If we have meaningful words, use first 3-4 of them
    if ($meaningfulWords.Count -gt 0) {
        $maxWords = if ($meaningfulWords.Count -eq 4) { 4 } else { 3 }
        $result = ($meaningfulWords | Select-Object -First $maxWords) -join '-'
        return $result
    } else {
        # Fallback to original logic if no meaningful words found
        $result = ConvertTo-CleanBranchName -Name $Description
        $fallbackWords = ($result -split '-') | Where-Object { $_ } | Select-Object -First 3
        return [string]::Join('-', $fallbackWords)
    }
}

# Generate branch name
if ($ShortName) {
    # Use provided short name, just clean it up
    $branchSuffix = ConvertTo-CleanBranchName -Name $ShortName
} else {
    # Generate from description with smart filtering
    $branchSuffix = Get-BranchName -Description $featureDesc
}

# Warn if -Number and -Timestamp are both specified
if ($Timestamp -and $Number -ne 0) {
    Write-Warning "[specify] Warning: -Number is ignored when -Timestamp is used"
    $Number = 0
}

# Determine branch prefix
if ($Timestamp) {
    $featureNum = Get-Date -Format 'yyyyMMdd-HHmmss'
    $branchName = "$featureNum-$branchSuffix"
} else {
    # Determine branch number from existing feature directories
    if ($Number -eq 0) {
        $Number = (Get-HighestNumberFromSpecs -SpecsDir $specsDir) + 1
    }

    $featureNum = ('{0:000}' -f $Number)
    $branchName = "$featureNum-$branchSuffix"
}

# GitHub enforces a 244-byte limit on branch names
# Validate and truncate if necessary
$maxBranchLength = 244
if ($branchName.Length -gt $maxBranchLength) {
    # Calculate how much we need to trim from suffix
    # Account for prefix length: timestamp (15) + hyphen (1) = 16, or sequential (3) + hyphen (1) = 4
    $prefixLength = $featureNum.Length + 1
    $maxSuffixLength = $maxBranchLength - $prefixLength

    # Truncate suffix
    $truncatedSuffix = $branchSuffix.Substring(0, [Math]::Min($branchSuffix.Length, $maxSuffixLength))
    # Remove trailing hyphen if truncation created one
    $truncatedSuffix = $truncatedSuffix -replace '-$', ''

    $originalBranchName = $branchName
    $branchName = "$featureNum-$truncatedSuffix"

    Write-Warning "[specify] Branch name exceeded GitHub's 244-byte limit"
    Write-Warning "[specify] Original: $originalBranchName ($($originalBranchName.Length) bytes)"
    Write-Warning "[specify] Truncated to: $branchName ($($branchName.Length) bytes)"
}

$featureDir = Join-Path $specsDir $branchName
$specFile = Join-Path $featureDir 'spec.md'

if (-not $DryRun) {
    if ((Test-Path -LiteralPath $featureDir -PathType Container) -and -not $AllowExistingBranch) {
        if ($Timestamp) {
            Write-Error "Error: Feature directory '$featureDir' already exists. Rerun to get a new timestamp or use a different -ShortName."
        } else {
            Write-Error "Error: Feature directory '$featureDir' already exists. Please use a different feature name or specify a different number with -Number."
        }
        exit 1
    }

    New-Item -ItemType Directory -Path $featureDir -Force | Out-Null

    if (-not (Test-Path -PathType Leaf $specFile)) {
        $template = Resolve-Template -TemplateName 'spec-template' -RepoRoot $repoRoot
        if ($template -and (Test-Path $template)) {
            # Read the template content and write it to the spec file with UTF-8 encoding without BOM
            $content = [System.IO.File]::ReadAllText($template)
            $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
            [System.IO.File]::WriteAllText($specFile, $content, $utf8NoBom)
        } else {
            New-Item -ItemType File -Path $specFile -Force | Out-Null
        }
    }

    # Persist to .specify/feature.json so downstream commands can find the feature
    Save-FeatureJson -RepoRoot $repoRoot -FeatureDirectory $featureDir

    # Set environment variables for the current session
    $env:SPECIFY_FEATURE = $branchName
    $env:SPECIFY_FEATURE_DIRECTORY = $featureDir
}

if ($Json) {
    $obj = [PSCustomObject]@{
        BRANCH_NAME = $branchName
        SPEC_FILE = $specFile
        FEATURE_NUM = $featureNum
    }
    if ($DryRun) {
        $obj | Add-Member -NotePropertyName 'DRY_RUN' -NotePropertyValue $true
    }
    $obj | ConvertTo-Json -Compress
} else {
    Write-Output "BRANCH_NAME: $branchName"
    Write-Output "SPEC_FILE: $specFile"
    Write-Output "FEATURE_NUM: $featureNum"
    if (-not $DryRun) {
        Write-Output "SPECIFY_FEATURE set to: $branchName"
        Write-Output "SPECIFY_FEATURE_DIRECTORY set to: $featureDir"
    }
}
