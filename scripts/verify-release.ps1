[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot

Write-Host "Starting Validated-by-Design release verification..."

$releases = @(
    @{
        Book = '1'
        Version = 'v1.0.1'
        Pdf = 'validated-by-design-book-1-v1.0.1.pdf'
    },
    @{
        Book = '2'
        Version = 'v2.0.0'
        Pdf = 'validated-by-design-book-2-v2.0.0.pdf'
    }
)

$requiredRootFiles = @(
    '.nojekyll',
    '.zenodo.json',
    'CITATION.cff',
    'LICENSE',
    'PUBLISHING.md',
    'README.md',
    'index.html'
)

$failures = New-Object System.Collections.Generic.List[string]

# Check required root files.
foreach ($relativePath in $requiredRootFiles) {

    $absolutePath = Join-Path $repositoryRoot $relativePath

    if (-not (Test-Path -LiteralPath $absolutePath -PathType Leaf)) {
        $failures.Add(
            "Missing required file: $relativePath"
        )
    }
}

# Validate .zenodo.json.
$zenodoPath = Join-Path $repositoryRoot '.zenodo.json'

if (Test-Path -LiteralPath $zenodoPath -PathType Leaf) {

    try {
        $zenodoContent = Get-Content `
            -LiteralPath $zenodoPath `
            -Raw

        $zenodoContent |
            ConvertFrom-Json |
            Out-Null
    }
    catch {
        $failures.Add(
            "Invalid .zenodo.json: $($_.Exception.Message)"
        )
    }
}

# Load index.html.
$landingPagePath = Join-Path $repositoryRoot 'index.html'
$landingPage = ''

if (Test-Path -LiteralPath $landingPagePath -PathType Leaf) {

    $landingPage = Get-Content `
        -LiteralPath $landingPagePath `
        -Raw
}

$publicFiles = @(
    'README.md',
    'CITATION.cff',
    '.zenodo.json',
    'index.html'
)

# Validate every configured release.
foreach ($release in $releases) {

    $bookNumber = $release.Book
    $version = $release.Version
    $pdfFileName = $release.Pdf

    Write-Host "Checking Book $bookNumber $version..."

    $releaseDirectory = "releases/$version"

    $pdfRelativePath =
        "$releaseDirectory/$pdfFileName"

    $releaseNotesRelativePath =
        "$releaseDirectory/RELEASE-NOTES.md"

    $checksumRelativePath =
        "$releaseDirectory/SHA256SUMS.txt"

    $pdfPath =
        Join-Path $repositoryRoot $pdfRelativePath

    $releaseNotesPath =
        Join-Path $repositoryRoot $releaseNotesRelativePath

    $checksumPath =
        Join-Path $repositoryRoot $checksumRelativePath

    # Check PDF.
    if (-not (Test-Path -LiteralPath $pdfPath -PathType Leaf)) {

        $failures.Add(
            "Missing Book $bookNumber PDF: $pdfRelativePath"
        )
    }

    # Check release notes.
    if (-not (
        Test-Path `
            -LiteralPath $releaseNotesPath `
            -PathType Leaf
    )) {

        $failures.Add(
            "Missing Book $bookNumber release notes: $releaseNotesRelativePath"
        )
    }

    # Check checksum file.
    if (-not (
        Test-Path `
            -LiteralPath $checksumPath `
            -PathType Leaf
    )) {

        $failures.Add(
            "Missing Book $bookNumber checksum file: $checksumRelativePath"
        )
    }

    $pdfExists =
        Test-Path `
            -LiteralPath $pdfPath `
            -PathType Leaf

    $checksumExists =
        Test-Path `
            -LiteralPath $checksumPath `
            -PathType Leaf

    # Validate SHA-256.
    if ($pdfExists -and $checksumExists) {

        $checksumText =
            Get-Content `
                -LiteralPath $checksumPath `
                -Raw

        $checksumText = $checksumText.Trim()

        if ($checksumText.Length -eq 0) {

            $failures.Add(
                "Checksum file is empty for Book $bookNumber."
            )
        }
        else {

            $checksumParts =
                $checksumText -split '\s+'

            $expectedPdfHash =
                $checksumParts[0].ToUpperInvariant()

            if (
                $expectedPdfHash -notmatch
                '^[A-F0-9]{64}$'
            ) {

                $failures.Add(
                    "Invalid SHA-256 value for Book $bookNumber in $checksumRelativePath"
                )
            }
            else {

                $actualPdfHash = (
                    Get-FileHash `
                        -LiteralPath $pdfPath `
                        -Algorithm SHA256
                ).Hash.ToUpperInvariant()

                if (
                    $actualPdfHash -ne
                    $expectedPdfHash
                ) {

                    $failures.Add(
                        "PDF hash mismatch for Book $bookNumber. Expected $expectedPdfHash; received $actualPdfHash"
                    )
                }
                else {

                    Write-Host (
                        "Book $bookNumber SHA-256 verified: $actualPdfHash"
                    )
                }
            }

            # Validate filename in SHA256SUMS.txt.
            if ($checksumParts.Count -ge 2) {

                $checksumFileName =
                    $checksumParts[-1]

                $checksumFileName =
                    $checksumFileName.TrimStart('*')

                if (
                    $checksumFileName -ne
                    $pdfFileName
                ) {

                    $failures.Add(
                        "Checksum filename mismatch for Book $bookNumber. Expected $pdfFileName; received $checksumFileName"
                    )
                }
            }
            else {

                $failures.Add(
                    "Checksum filename is missing for Book $bookNumber in $checksumRelativePath"
                )
            }
        }
    }

    # Check canonical PDF link in index.html.
    $expectedLink =
        "*$pdfRelativePath*"

    if ($landingPage -notlike $expectedLink) {

        $failures.Add(
            "The landing page does not link to the Book $bookNumber canonical PDF: $pdfRelativePath"
        )
    }

    $publicFiles +=
        $releaseNotesRelativePath
}

# Load public-facing text.
$publicTextParts = @()

foreach ($publicFile in $publicFiles) {

    $publicFilePath =
        Join-Path $repositoryRoot $publicFile

    if (
        Test-Path `
            -LiteralPath $publicFilePath `
            -PathType Leaf
    ) {

        $content =
            Get-Content `
                -LiteralPath $publicFilePath `
                -Raw

        $publicTextParts += $content
    }
}

$joinedPublicText =
    $publicTextParts -join "`n"

# Validate surname spelling.
if ($joinedPublicText -match 'Telluri') {

    $failures.Add(
        'Public repository text contains the misspelled surname Telluri.'
    )
}

if ($joinedPublicText -notmatch 'Tulluri') {

    $failures.Add(
        'Public repository text does not contain the corrected surname Tulluri.'
    )
}

# Report failures.
if ($failures.Count -gt 0) {

    Write-Host ''
    Write-Host 'Release verification failed:' `
        -ForegroundColor Red

    foreach ($failure in $failures) {

        Write-Host (
            " - $failure"
        ) -ForegroundColor Red
    }

    exit 1
}

# Report success.
Write-Host ''
Write-Host 'Release verification passed:' `
    -ForegroundColor Green

Write-Host ' - Book 1 v1.0.1' `
    -ForegroundColor Green

Write-Host ' - Book 2 v2.0.0' `
    -ForegroundColor Green

exit 0