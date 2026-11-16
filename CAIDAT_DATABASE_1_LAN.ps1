#Requires -Version 5.1
# Chay bo cai dat SQL Server LocalDB MyStore bang Windows PowerShell va ADO.NET.
# KHONG CAN cai dat SQL Server Management Studio hay Invoke-Sqlcmd.
$ErrorActionPreference = 'Stop'
$serverName = '(localdb)\MSSQLLocalDB'
$dbFolder = Join-Path $PSScriptRoot 'Database'
$files = @('01_Create_MyStore.sql', '02_Seed_SampleData.sql')

# Hoi dap thong qua Windows integrated security; chay tren dung LocalDB user hien tai.
$builder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
$builder['Data Source'] = $serverName
$builder['Initial Catalog'] = 'master'
$builder['Integrated Security'] = $true
$builder['Connect Timeout'] = 30
$builder['TrustServerCertificate'] = $true
$connection = New-Object System.Data.SqlClient.SqlConnection($builder.ConnectionString)

function Invoke-SqlBatches([string]$filePath) {
    $sql = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
    # GO la batch separator cua SSMS, KHONG PHAI cau lenh T-SQL.
    $batches = [System.Text.RegularExpressions.Regex]::Split(
        $sql,
        '(?im)^[ \t]*GO[ \t]*(?:--[^\r\n]*)?(?:\r?\n|$)'
    )
    $batchNumber = 0
    foreach ($batch in $batches) {
        if ([string]::IsNullOrWhiteSpace($batch)) { continue }
        $batchNumber += 1
        $cmd = $connection.CreateCommand()
        $cmd.CommandText = $batch
        $cmd.CommandTimeout = 120
        try {
            [void]$cmd.ExecuteNonQuery()
        } catch {
            throw "SQL ERROR - $([System.IO.Path]::GetFileName($filePath)), batch $batchNumber : $($_.Exception.Message)"
        } finally {
            $cmd.Dispose()
        }
    }
    Write-Host "OK - $([System.IO.Path]::GetFileName($filePath)) ($batchNumber batches)" -ForegroundColor Green
}

try {
    Write-Host '=================================================='
    Write-Host "Connecting SQL LocalDB: $serverName"
    $connection.Open()
    Write-Host 'Connected.' -ForegroundColor Green

    foreach ($fileName in $files) {
        $path = Join-Path $dbFolder $fileName
        if (-not (Test-Path -LiteralPath $path)) { throw "Cannot find: $path" }
        Write-Host "Running: $fileName"
        Invoke-SqlBatches $path
    }

    $cmd = $connection.CreateCommand()
    $cmd.CommandText = 'SELECT COUNT(*) FROM [MyStore].dbo.Product;'
    $total = [int]$cmd.ExecuteScalar()
    $cmd.Dispose()
    Write-Host "SUCCESS - Database MyStore is ready. Products: $total" -ForegroundColor Green
    Write-Host 'You can open MyStore_MVC5_Full.sln in Visual Studio 2022 and press F5.'
} catch {
    Write-Host 'DATABASE SETUP FAILED:' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host 'Copy this error message or take a screenshot to diagnose it.'
    exit 1
} finally {
    if ($null -ne $connection) { $connection.Dispose() }
}
