param(
    [Parameter(Mandatory = $false)]
    [string]$LuauAnalyzePath = "luau-analyze"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$lessonRoot = Join-Path $repoRoot "docs\lessons"
$lessons = Get-ChildItem -LiteralPath $lessonRoot -File -Filter "*.luau" | Sort-Object Name
$markdownFiles = Get-ChildItem -LiteralPath (Join-Path $repoRoot "docs") -File -Filter "*.md" -Recurse

if ($lessons.Count -eq 0) {
    throw "No curriculum lessons were found in $lessonRoot"
}

$embeddedPattern = '(?s)<!-- BEGIN VERIFIED LESSON: (?<Name>[A-Za-z0-9_]+\.luau) -->\r?\n```luau\r?\n(?<Code>.*?)\r?\n```\r?\n<!-- END VERIFIED LESSON: (?<EndName>[A-Za-z0-9_]+\.luau) -->'
$embeddedCounts = @{}
$embeddingFailures = @()

foreach ($markdownFile in $markdownFiles) {
    $markdown = Get-Content -LiteralPath $markdownFile.FullName -Raw
    foreach ($match in [regex]::Matches($markdown, $embeddedPattern)) {
        $lessonName = $match.Groups["Name"].Value
        $endName = $match.Groups["EndName"].Value
        if ($lessonName -ne $endName) {
            $embeddingFailures += "$($markdownFile.Name): marker names do not match"
            continue
        }

        $lessonPath = Join-Path $lessonRoot $lessonName
        if (-not (Test-Path -LiteralPath $lessonPath)) {
            $embeddingFailures += "$($markdownFile.Name): missing $lessonName"
            continue
        }

        $embeddedCode = $match.Groups["Code"].Value.Replace("`r`n", "`n")
        $sourceCode = (Get-Content -LiteralPath $lessonPath -Raw).Replace("`r`n", "`n").TrimEnd([char]10)
        if ($embeddedCode -cne $sourceCode) {
            $embeddingFailures += "$($markdownFile.Name): embedded $lessonName differs from its source file"
        }

        if (-not $embeddedCounts.ContainsKey($lessonName)) {
            $embeddedCounts[$lessonName] = 0
        }
        $embeddedCounts[$lessonName] += 1
    }
}

foreach ($lesson in $lessons) {
    if (-not $embeddedCounts.ContainsKey($lesson.Name)) {
        $embeddingFailures += "$($lesson.Name): no embedded curriculum example"
    } elseif ($embeddedCounts[$lesson.Name] -ne 1) {
        $embeddingFailures += "$($lesson.Name): embedded $($embeddedCounts[$lesson.Name]) times"
    }
}

if ($embeddingFailures.Count -gt 0) {
    throw "Embedded lesson verification failed: $($embeddingFailures -join '; ')"
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

Write-Output "Verified and type-checked $($lessons.Count) embedded curriculum lessons."
