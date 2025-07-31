param(
    [string]$Server = "SERVER",
    [string]$Database = "DATABASE",
    [string]$DestinationTable = "[SCHEMA].[TABLE]",
    [string]$InputFile = "PATH",
    [string]$Username = "",
    [string]$Password = "",
    [switch]$UseWindowsAuth = $true, #True = Local Server
    [string]$FieldTerminator = ",",
    [string]$RowTerminator = "\n",
    [int]$PacketSize = 65536,
    [int]$BatchSize = 50000
)

# Check if input file exists
if (-not (Test-Path $InputFile)) {
    Write-Host "Input file not found: $InputFile" -ForegroundColor Red
    exit 1
}

$fileSize = (Get-Item $InputFile).Length / 1GB
Write-Host "Starting BCP import..." -ForegroundColor Green
Write-Host "File: $InputFile ($($fileSize.ToString('0.00')) GB)" -ForegroundColor Green
$startTime = Get-Date

# Build connection string based on authentication type
if ($UseWindowsAuth) {
    $connectionParams = "-S `"$Server`" -T"
} else {
    $connectionParams = "-S `"$Server`" -U `"$Username`" -P `"$Password`""
}

# Build import command
$importCmd = "bcp `"$DestinationTable`" in `"$InputFile`" $connectionParams -d `"$Database`" -c -t`"$FieldTerminator`" -r`"$RowTerminator`" -a $PacketSize -b $BatchSize"

Write-Host "Executing BCP import..."

# Execute BCP command directly
try {
    Invoke-Expression $importCmd
    
    if ($LASTEXITCODE -eq 0) {
        $duration = ((Get-Date) - $startTime).TotalMinutes
        Write-Host "Import completed successfully!" -ForegroundColor Green
        Write-Host "Table: $DestinationTable" -ForegroundColor Green
        Write-Host "Duration: $($duration.ToString('0.00')) minutes" -ForegroundColor Green
    } else {
        Write-Host "Import failed - BCP exit code: $LASTEXITCODE" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Import failed: $_" -ForegroundColor Red
    exit 1
}