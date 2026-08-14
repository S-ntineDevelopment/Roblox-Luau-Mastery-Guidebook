param(
    [Parameter(Mandatory = $false)]
    [string]$LuauAnalyzePath = "luau-analyze"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$lessonRoot = Join-Path $repoRoot "docs\lessons"
$lessons = Get-ChildItem -LiteralPath $lessonRoot -File -Filter "*.luau" | Sort-Object Name

if ($lessons.Count -eq 0) {
    throw "No curriculum lessons were found in $lessonRoot"
}

$failures = @()
foreach ($lesson in $lessons) {
    & $LuauAnalyzePath $lesson.FullName
    if ($LASTEXITCODE -ne 0) {
        $failures += $lesson.Name
    }
}

if ($failures.Count -gt 0) {
    throw "Luau analysis failed for: $($failures -join ', ')"
}

Write-Output "Type-checked $($lessons.Count) curriculum lessons."
