# move-and-rename.ps1
# Batch rename and relocate Azure subscriptions to a target Management Group

$TARGET_MG = "mg-workloads-sandbox"
$DRY_RUN   = $true  # Set to $false to execute
$counter   = 1
$PREFIX    = "legacy-sub"
$REGEX     = '^legacy-sub-\d+$'

# ──────────────────────────────────────────────
# 1. Fetch Subscriptions matching prefix
# ──────────────────────────────────────────────
Write-Host "=== Fetching subscriptions matching prefix '$PREFIX' ===" -ForegroundColor Cyan

$allSubs = az account list --all `
    --query "[?starts_with(name, '$PREFIX') && state=='Enabled'].{name:name, id:id}" `
    -o json | ConvertFrom-Json

# Strict regex match (excludes unwanted naming variants)
$subs = $allSubs | Where-Object { $_.name -match $REGEX } | Sort-Object name

Write-Host "Found $($subs.Count) matching subscription(s)`n"

# Display excluded subscriptions
$excluded = $allSubs | Where-Object { $_.name -notmatch $REGEX }
if ($excluded) {
    Write-Host "=== EXCLUDED ===" -ForegroundColor DarkGray
    foreach ($ex in $excluded) {
        Write-Host "  [-] $($ex.name)" -ForegroundColor DarkGray
    }
    Write-Host ""
}

# ──────────────────────────────────────────────
# 2. Preview Plan
# ──────────────────────────────────────────────
Write-Host "=== PLAN ===" -ForegroundColor Yellow
$previewCounter = $counter
foreach ($sub in $subs) {
    $num = "{0:D2}" -f $previewCounter
    $newName = "sub-sandbox-$num"
    Write-Host "  $($sub.name) -> $newName  (move to $TARGET_MG)"
    $previewCounter++
}
Write-Host ""

if ($DRY_RUN) {
    Write-Host "DRY RUN — set `$DRY_RUN = `$false in script to execute" -ForegroundColor Yellow
    exit 0
}

# ──────────────────────────────────────────────
# 3. Execution
# ──────────────────────────────────────────────
Write-Host "=== EXECUTING ===" -ForegroundColor Green
$errors = 0
$success = 0

foreach ($sub in $subs) {
    $num = "{0:D2}" -f $counter
    $newName = "sub-sandbox-$num"

    # Step 1: Rename subscription
    Write-Host -NoNewline "[$($sub.name)] Renaming -> $newName ... "
    az account subscription rename --subscription-id $sub.id --name $newName 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK" -ForegroundColor Green
    } else {
        Write-Host "FAILED" -ForegroundColor Red
        $errors++
        continue
    }

    # Step 2: Move to target Management Group
    Write-Host -NoNewline "[$newName] Moving -> $TARGET_MG ... "
    az account management-group subscription add --name $TARGET_MG --subscription $sub.id 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK" -ForegroundColor Green
        $success++
    } else {
        Write-Host "FAILED" -ForegroundColor Red
        $errors++
    }

    $counter++
    Start-Sleep -Seconds 2
}

Write-Host "`n=== DONE — Success: $success | Errors: $errors ===" -ForegroundColor Cyan
