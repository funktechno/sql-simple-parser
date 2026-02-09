if (Test-Path "version-*.txt") {
    Write-Host "Found existing version-*.txt file(s), reading version information from it."
    $versionFile = Get-ChildItem "version-*.txt" | Select-Object -First 1
    $content = Get-Content $versionFile.FullName
    $VERSION = ($content | Where-Object { $_ -match "^version=" }) -replace "^version=", ""
    $MAJOR_MINOR_PATCH = ($content | Where-Object { $_ -match "^major_minor_patch=" }) -replace "^major_minor_patch=", ""
    $FULL_SEMVER = ($content | Where-Object { $_ -match "^full_semver=" }) -replace "^full_semver=", ""
    $GIT_HASH = ($content | Where-Object { $_ -match "^git_hash=" }) -replace "^git_hash=", ""
    $GIT_TAG = ($content | Where-Object { $_ -match "^git_tag=" }) -replace "^git_tag=", ""
    $GIT_BRANCH = ($content | Where-Object { $_ -match "^git_branch=" }) -replace "^git_branch=", ""
    $COMMIT_COUNT = ($content | Where-Object { $_ -match "^commit_count=" }) -replace "^commit_count=", ""
    $BUILD_DATE = ($content | Where-Object { $_ -match "^build_date=" }) -replace "^build_date=", ""
} else {
    Write-Host "No existing version-*.txt file found, using fallback version information."
    $VERSION = "0.0.2-fallback"
    $MAJOR_MINOR_PATCH = "0.0.2"
    $FULL_SEMVER = "0.0.2-fallback"
    $GIT_HASH = "unknown"
    $GIT_TAG = "allback"
    $GIT_BRANCH = "unknown"
    $COMMIT_COUNT = "0"
    $BUILD_DATE = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

Write-Output "VERSION=$VERSION" >> $env:GITHUB_OUTPUT
Write-Output "MAJOR_MINOR_PATCH=$MAJOR_MINOR_PATCH" >> $env:GITHUB_OUTPUT
Write-Output "FULL_SEMVER=$FULL_SEMVER" >> $env:GITHUB_OUTPUT
Write-Output "GIT_HASH=$GIT_HASH" >> $env:GITHUB_OUTPUT
Write-Output "GIT_TAG=$GIT_TAG" >> $env:GITHUB_OUTPUT
Write-Output "GIT_BRANCH=$GIT_BRANCH" >> $env:GITHUB_OUTPUT
Write-Output "COMMIT_COUNT=$COMMIT_COUNT" >> $env:GITHUB_OUTPUT
Write-Output "BUILD_DATE=$BUILD_DATE" >> $env:GITHUB_OUTPUT

Write-Host "Using version: $VERSION"
Write-Host "Major minor patch: $MAJOR_MINOR_PATCH"
Write-Host "Full semver: $FULL_SEMVER"
Write-Host "Git hash: $GIT_HASH"
Write-Host "Git branch: $GIT_BRANCH"
Write-Host "Commit count: $COMMIT_COUNT"
Write-Host "Build date: $BUILD_DATE"

# Parse MAJOR, MINOR, PATCH from MAJOR_MINOR_PATCH (format: "MAJOR.MINOR.PATCH")
$versionParts = $MAJOR_MINOR_PATCH -split '\.'
$MAJOR = if ($versionParts.Count -gt 0) { [int]$versionParts[0] } else { 0 }
$MINOR = if ($versionParts.Count -gt 1) { [int]$versionParts[1] } else { 0 }
$PATCH = if ($versionParts.Count -gt 2) { [int]$versionParts[2] } else { 0 }

# Compute versionCode: MAJOR * 1000000 + MINOR * 10000 + PATCH * 100 + COMMIT_COUNT
$VERSION_CODE = $MAJOR * 1000000 + $MINOR * 10000 + $PATCH * 100 + [int]$COMMIT_COUNT
Write-Host "Android versionCode: $VERSION_CODE (MAJOR=$MAJOR MINOR=$MINOR PATCH=$PATCH COMMIT_COUNT=$COMMIT_COUNT)"

# Update package.json only
$packageJson = "package.json"
if (Test-Path $packageJson) {
    # Read file as raw text to perform a single replace operation
    $content = Get-Content $packageJson -Raw
    $replacement = '"version": "' + $VERSION + '"'
    $new = $content -replace '"version"\s*:\s*"[^"]*"', $replacement
    Set-Content -Path $packageJson -Value $new
    Write-Host "Updated $packageJson to version $VERSION"
} else {
    Write-Host "package.json not found: $packageJson"
}

Write-Host "Version update complete."
