param(
    [string]$Server = "SERVER",
    [string]$Database = "DATABASE",
    [string]$SourceTable = "[SCHEMA].[TABLE]",
    [string]$OutputFile = "PATH",
    [string]$Username = "USER",
    [string]$Password = "PASS!",
    [switch]$UseWindowsAuth = $false, #True = Local Server
    [int]$PacketSize = 65536,
    [string]$FieldTerminator = ",",
    [string]$RowTerminator = "\n",
    [string]$WhereClause = "WHERE CLAUSE"
)

# Ensure output directory exists
$outputDir = Split-Path -Path $OutputFile -Parent
if (-not (Test-Path $outputDir)) { New-Item -Path $outputDir -ItemType Directory -Force | Out-Null }

Write-Host "Starting BCP export..." -ForegroundColor Green
$startTime = Get-Date

# Build connection string based on authentication type
if ($UseWindowsAuth) {
    $connectionParams = "-S `"$Server`" -T"
} else {
    $connectionParams = "-S `"$Server`" -U `"$Username`" -P `"$Password`""
}

# Build export command
$exportCmd = if ($WhereClause) {
    $query = "`"SELECT * FROM $SourceTable WHERE $WhereClause`""
    "bcp $query queryout `"$OutputFile`" $connectionParams -d `"$Database`" -c -t`"$FieldTerminator`" -r`"$RowTerminator`" -a $PacketSize"
} else {
    "bcp `"$SourceTable`" out `"$OutputFile`" $connectionParams -d `"$Database`" -c -t`"$FieldTerminator`" -r`"$RowTerminator`" -a $PacketSize"
}

Write-Host "Executing BCP..."

# Execute BCP command directly
try {
    Invoke-Expression $exportCmd
    
    if (Test-Path $OutputFile) {
        $fileSize = (Get-Item $OutputFile).Length / 1GB
        $duration = ((Get-Date) - $startTime).TotalMinutes
        Write-Host "Export completed successfully!" -ForegroundColor Green
        Write-Host "File: $OutputFile" -ForegroundColor Green
        Write-Host "Size: $($fileSize.ToString('0.00')) GB" -ForegroundColor Green
        Write-Host "Duration: $($duration.ToString('0.00')) minutes" -ForegroundColor Green
    } else {
        Write-Host "Export failed - no output file created" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Export failed: $_" -ForegroundColor Red
    exit 1
}