param(
    [Parameter(Mandatory = $false)]
    [string]$LuauAnalyzePath = "luau-analyze"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$docsRoot = Join-Path $repoRoot "docs"
$lessonRoot = Join-Path $repoRoot "docs\lessons"
$lessons = Get-ChildItem -LiteralPath $lessonRoot -File -Filter "*.luau" | Sort-Object Name
$markdownFiles = Get-ChildItem -LiteralPath $docsRoot -File -Filter "*.md" -Recurse
$stageFiles = @(
    Get-ChildItem -LiteralPath $docsRoot -File -Filter "STAGE_*.md" |
        Where-Object { $_.Name -match '^STAGE_\d{2}_.+\.md$' } |
        Sort-Object Name
)
$expectedStageCount = 22

if ($lessons.Count -eq 0) {
    throw "No curriculum lessons were found in $lessonRoot"
}

$structureFailures = @()
$readme = Get-Content -LiteralPath (Join-Path $repoRoot "README.md") -Encoding UTF8 -Raw
$master = Get-Content -LiteralPath (Join-Path $docsRoot "ROBLOX_LUAU_MASTERY_CURRICULUM.md") -Encoding UTF8 -Raw
$coverageMap = Get-Content -LiteralPath (Join-Path $docsRoot "STAGE_COVERAGE_AND_DIFFICULTY_MAP.md") -Encoding UTF8 -Raw
$previousReadmeIndex = -1
$previousMasterIndex = -1
$previousCoverageIndex = -1

if ($stageFiles.Count -ne $expectedStageCount) {
    $structureFailures += "expected $expectedStageCount stage files, found $($stageFiles.Count)"
}

for ($stageNumber = 1; $stageNumber -le $expectedStageCount; $stageNumber++) {
    $prefix = "STAGE_{0:D2}_" -f $stageNumber
    $matches = @($stageFiles | Where-Object { $_.Name.StartsWith($prefix, [System.StringComparison]::Ordinal) })
    if ($matches.Count -ne 1) {
        $structureFailures += "Stage $stageNumber has $($matches.Count) matching files"
        continue
    }

    $stageFile = $matches[0]
    $stageText = Get-Content -LiteralPath $stageFile.FullName -Encoding UTF8 -Raw
    if ($stageText -notmatch "(?m)^# Stage ${stageNumber}: ") {
        $structureFailures += "$($stageFile.Name): title does not declare Stage $stageNumber"
    }

    $expectedRank = "{0:D2}/$expectedStageCount" -f $stageNumber
    if ($stageText -notmatch "(?m)^\*\*Difficulty rank:\*\* $([regex]::Escape($expectedRank)) ") {
        $structureFailures += "$($stageFile.Name): missing difficulty rank $expectedRank"
    }

    $expectedLessonPrefix = "STAGE_{0:D2}_" -f $stageNumber
    if ($stageText -notmatch "<!-- BEGIN VERIFIED LESSON: $expectedLessonPrefix[A-Za-z0-9_]*\.luau -->") {
        $structureFailures += "$($stageFile.Name): embedded lesson number does not match"
    }

    $readmeLink = "docs/$($stageFile.Name)"
    $readmeIndex = $readme.IndexOf($readmeLink, [System.StringComparison]::Ordinal)
    if ($readmeIndex -lt 0) {
        $structureFailures += "$($stageFile.Name): missing from README order"
    } elseif ($readmeIndex -le $previousReadmeIndex) {
        $structureFailures += "$($stageFile.Name): README order is not ascending"
    } else {
        $previousReadmeIndex = $readmeIndex
    }

    $masterIndex = $master.IndexOf($stageFile.Name, [System.StringComparison]::Ordinal)
    if ($masterIndex -lt 0) {
        $structureFailures += "$($stageFile.Name): missing from master curriculum order"
    } elseif ($masterIndex -le $previousMasterIndex) {
        $structureFailures += "$($stageFile.Name): master curriculum order is not ascending"
    } else {
        $previousMasterIndex = $masterIndex
    }

    $coverageIndex = $coverageMap.IndexOf($stageFile.Name, [System.StringComparison]::Ordinal)
    if ($coverageIndex -lt 0) {
        $structureFailures += "$($stageFile.Name): missing from coverage map"
    } elseif ($coverageIndex -le $previousCoverageIndex) {
        $structureFailures += "$($stageFile.Name): coverage map order is not ascending"
    } else {
        $previousCoverageIndex = $coverageIndex
    }
}

if ($structureFailures.Count -gt 0) {
    throw "Curriculum structure verification failed: $($structureFailures -join '; ')"
}

$embeddedPattern = '(?s)<!-- BEGIN VERIFIED LESSON: (?<Name>[A-Za-z0-9_]+\.luau) -->\r?\n```luau\r?\n(?<Code>.*?)\r?\n```\r?\n<!-- END VERIFIED LESSON: (?<EndName>[A-Za-z0-9_]+\.luau) -->'
$embeddedCounts = @{}
$embeddingFailures = @()

foreach ($markdownFile in $markdownFiles) {
    $markdown = Get-Content -LiteralPath $markdownFile.FullName -Encoding UTF8 -Raw
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
        $sourceCode = (Get-Content -LiteralPath $lessonPath -Encoding UTF8 -Raw).Replace("`r`n", "`n").TrimEnd([char]10)
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

Write-Output "Verified $expectedStageCount contiguous stages and type-checked $($lessons.Count) embedded curriculum lessons."
