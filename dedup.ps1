$folder = $PSScriptRoot
$output = Join-Path $folder "image_hash_report.csv"
$uniqueFolder = Join-Path $folder "Unique_Images"

Write-Host ""
Write-Host "Scanning folder:"
Write-Host $folder
Write-Host ""

$extensions = @(".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp", ".tif", ".tiff", ".heic")

$files = Get-ChildItem -LiteralPath $folder -File | Where-Object {
    $extensions -contains $_.Extension.ToLower()
}

if (-not $files) {
    Write-Host "No image files found."
    Write-Host ""
    Read-Host "Press Enter to close"
    exit
}

$results = foreach ($file in $files) {
    Write-Host "Hashing $($file.Name)"

    try {
        $hash = Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256 -ErrorAction Stop

        [PSCustomObject]@{
            FileName  = $file.Name
            FullPath  = $file.FullName
            SizeBytes = $file.Length
            SHA256    = $hash.Hash
        }
    }
    catch {
        Write-Host "ERROR hashing $($file.Name): $($_.Exception.Message)"
    }
}

if (-not $results) {
    Write-Host ""
    Write-Host "No files were successfully hashed."
    Read-Host "Press Enter to close"
    exit
}

$hashCounts = @{}

foreach ($result in $results) {
    if ($hashCounts.ContainsKey($result.SHA256)) {
        $hashCounts[$result.SHA256]++
    }
    else {
        $hashCounts[$result.SHA256] = 1
    }
}

$final = foreach ($result in $results) {
    $count = $hashCounts[$result.SHA256]

    [PSCustomObject]@{
        FileName       = $result.FileName
        FullPath       = $result.FullPath
        SizeBytes      = $result.SizeBytes
        SHA256         = $result.SHA256
        DuplicateCount = $count
        IsDuplicate    = if ($count -gt 1) { "Yes" } else { "No" }
    }
}

$final |
    Sort-Object SHA256, FileName |
    Export-Csv -LiteralPath $output -NoTypeInformation -Encoding UTF8

$total = @($results).Count
$uniqueCount = @($results.SHA256 | Sort-Object -Unique).Count
$duplicateCopies = $total - $uniqueCount

Write-Host ""
Write-Host "DONE SCANNING"
Write-Host "------------------------"
Write-Host "Total image files: $total"
Write-Host "True unique images: $uniqueCount"
Write-Host "Duplicate copies: $duplicateCopies"
Write-Host ""
Write-Host "CSV created:"
Write-Host $output
Write-Host ""

$answer = Read-Host "Create a new folder containing ONE COPY of every unique image? (Y/N)"

if ($answer -match '^[Yy]$') {

    if (-not (Test-Path -LiteralPath $uniqueFolder)) {
        New-Item -ItemType Directory -Path $uniqueFolder | Out-Null
    }

    $uniqueResults = $results |
        Group-Object SHA256 |
        ForEach-Object {
            $_.Group | Select-Object -First 1
        }

    $copied = 0

    foreach ($item in $uniqueResults) {
        $destination = Join-Path $uniqueFolder $item.FileName

        # Avoid overwriting if the destination name already exists.
        if (Test-Path -LiteralPath $destination) {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($item.FileName)
            $extension = [System.IO.Path]::GetExtension($item.FileName)
            $counter = 2

            do {
                $newName = "$baseName`_$counter$extension"
                $destination = Join-Path $uniqueFolder $newName
                $counter++
            } while (Test-Path -LiteralPath $destination)
        }

        Copy-Item -LiteralPath $item.FullPath -Destination $destination
        $copied++
    }

    Write-Host ""
    Write-Host "Created:"
    Write-Host $uniqueFolder
    Write-Host ""
    Write-Host "Copied $copied unique images."
    Write-Host "Your original files were NOT changed or deleted."
}
else {
    Write-Host ""
    Write-Host "No files were copied."
}

Write-Host ""
Read-Host "Press Enter to close"
