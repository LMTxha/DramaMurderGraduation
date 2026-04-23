param(
    [switch]$Reset
)

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$appDataPath = Split-Path -Parent $projectRoot
$databaseName = 'DramaMurderGraduationDb'
$mdfPath = Join-Path $appDataPath ($databaseName + '.mdf')
$ldfPath = Join-Path $appDataPath ($databaseName + '_log.ldf')
$sqlFile = Join-Path $projectRoot 'Database\DramaMurder.sql'
$seedFile = Join-Path $projectRoot 'Database\SeedMockData.sql'

New-Item -ItemType Directory -Force -Path $appDataPath | Out-Null

$dropCommand = @"
IF DB_ID(N'$databaseName') IS NOT NULL
BEGIN
    BEGIN TRY
        ALTER DATABASE [$databaseName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE [$databaseName];
    END TRY
    BEGIN CATCH
        BEGIN TRY
            EXEC master.dbo.sp_detach_db @dbname = N'$databaseName', @skipchecks = 'true';
        END TRY
        BEGIN CATCH
            THROW;
        END CATCH
    END CATCH
END
"@

if ($Reset) {
    sqlcmd -b -f 65001 -S "(localdb)\MSSQLLocalDB" -Q $dropCommand
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to drop or detach database $databaseName."
    }

    Remove-Item -LiteralPath $mdfPath -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $ldfPath -Force -ErrorAction SilentlyContinue
}

$createCommand = @"
IF DB_ID(N'$databaseName') IS NULL
BEGIN
    CREATE DATABASE [$databaseName]
    ON PRIMARY (NAME = N'$databaseName', FILENAME = N'$($mdfPath.Replace("'", "''"))')
    LOG ON (NAME = N'${databaseName}_log', FILENAME = N'$($ldfPath.Replace("'", "''"))');
END
"@

sqlcmd -b -f 65001 -S "(localdb)\MSSQLLocalDB" -Q $createCommand
if ($LASTEXITCODE -ne 0) {
    throw "Failed to create database $databaseName."
}

sqlcmd -b -f 65001 -S "(localdb)\MSSQLLocalDB" -d $databaseName -i $sqlFile
if ($LASTEXITCODE -ne 0) {
    throw "Failed to initialize schema and seed data for $databaseName."
}

sqlcmd -b -f 65001 -S "(localdb)\MSSQLLocalDB" -d $databaseName -i $seedFile
if ($LASTEXITCODE -ne 0) {
    throw "Failed to seed mock data for $databaseName."
}

Write-Host ("数据库初始化完成: {0}" -f $databaseName)
