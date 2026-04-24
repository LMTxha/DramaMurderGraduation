param(
    [string]$ConnectionString = 'Data Source=(LocalDB)\MSSQLLocalDB;Initial Catalog=DramaMurderGraduationDb;Integrated Security=True;Connect Timeout=30;MultipleActiveResultSets=True',
    [string]$DatabaseName = 'DramaMurderGraduationDb',
    [string]$OutputPath = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $PSScriptRoot '..\DramaMurderGraduation.Web\Database\Generated\Deploy-DramaMurderGraduationDb.sql'
}

function Quote-Name {
    param([string]$Name)
    '[' + ($Name -replace ']', ']]') + ']'
}

function Escape-Literal {
    param([string]$Value)
    if ($null -eq $Value) {
        return ''
    }

    $Value.Replace("'", "''")
}

function Invoke-SqlTable {
    param(
        [string]$Sql,
        [hashtable]$Parameters = @{}
    )

    $connection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
    try {
        $connection.Open()
        $command = $connection.CreateCommand()
        $command.CommandText = $Sql
        foreach ($key in $Parameters.Keys) {
            $parameter = $command.Parameters.Add("@$key", [System.Data.SqlDbType]::Variant)
            $parameter.Value = $Parameters[$key]
        }

        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter $command
        $table = New-Object System.Data.DataTable
        [void]$adapter.Fill($table)
        return ,$table
    }
    finally {
        $connection.Dispose()
    }
}

function Get-TypeDefinition {
    param([System.Data.DataRow]$Column)

    $typeName = [string]$Column.DataType
    switch ($typeName) {
        'nvarchar' { '{0}({1})' -f $typeName, ($(if ($Column.max_length -eq -1) { 'MAX' } else { [int]$Column.max_length / 2 })) }
        'nchar' { '{0}({1})' -f $typeName, ([int]$Column.max_length / 2) }
        'varchar' { '{0}({1})' -f $typeName, ($(if ($Column.max_length -eq -1) { 'MAX' } else { [int]$Column.max_length })) }
        'char' { '{0}({1})' -f $typeName, ([int]$Column.max_length) }
        'varbinary' { '{0}({1})' -f $typeName, ($(if ($Column.max_length -eq -1) { 'MAX' } else { [int]$Column.max_length })) }
        'binary' { '{0}({1})' -f $typeName, ([int]$Column.max_length) }
        'decimal' { '{0}({1},{2})' -f $typeName, $Column.precision, $Column.scale }
        'numeric' { '{0}({1},{2})' -f $typeName, $Column.precision, $Column.scale }
        'datetime2' { '{0}({1})' -f $typeName, $Column.scale }
        'datetimeoffset' { '{0}({1})' -f $typeName, $Column.scale }
        'time' { '{0}({1})' -f $typeName, $Column.scale }
        default { $typeName }
    }
}

function Get-IndexColumnList {
    param(
        [System.Data.DataRow[]]$Rows,
        [bool]$Included
    )

    $selected = $Rows |
        Where-Object { [bool]$_.is_included_column -eq $Included } |
        Sort-Object @{ Expression = { if ($Included) { [int]$_.index_column_id } else { [int]$_.key_ordinal } } }

    if (-not $selected) {
        return ''
    }

    $parts = foreach ($row in $selected) {
        $direction = if (-not $Included -and [bool]$row.is_descending_key) { ' DESC' } else { '' }
        '{0}{1}' -f (Quote-Name ([string]$row.ColumnName)), $direction
    }

    $parts -join ', '
}

$outputDirectory = Split-Path -Path $OutputPath -Parent
if (-not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

$tables = Invoke-SqlTable @"
SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    t.object_id AS ObjectId
FROM sys.tables t
INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE t.is_ms_shipped = 0
ORDER BY s.name, t.name;
"@

$schemas = $tables.Rows |
    ForEach-Object { [string]$_.SchemaName } |
    Where-Object { $_ -ne 'dbo' } |
    Sort-Object -Unique

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add(':setvar DatabaseName "' + $DatabaseName + '"')
$lines.Add(':on error exit')
$lines.Add('')
$lines.Add('USE [master];')
$lines.Add('GO')
$lines.Add('')
$lines.Add("IF DB_ID(N'`$(DatabaseName)') IS NULL")
$lines.Add('BEGIN')
$lines.Add("    CREATE DATABASE [`$(DatabaseName)];")
$lines.Add('END')
$lines.Add('GO')
$lines.Add('')
$lines.Add("USE [`$(DatabaseName)];")
$lines.Add('GO')
$lines.Add('')
$lines.Add('SET ANSI_NULLS ON;')
$lines.Add('GO')
$lines.Add('')
$lines.Add('SET QUOTED_IDENTIFIER ON;')
$lines.Add('GO')
$lines.Add('')
$lines.Add('-- Generated from the current LocalDB schema')
$lines.Add('-- Source script: Tools/Generate-DatabaseDeployment.ps1')
$lines.Add('')

foreach ($schemaName in $schemas) {
    $lines.Add("IF SCHEMA_ID(N'" + (Escape-Literal $schemaName) + "') IS NULL")
    $lines.Add('BEGIN')
    $lines.Add("    EXEC(N'CREATE SCHEMA " + (Quote-Name $schemaName) + " AUTHORIZATION [dbo];');")
    $lines.Add('END')
    $lines.Add('GO')
    $lines.Add('')
}

foreach ($table in $tables.Rows) {
    $schemaName = [string]$table.SchemaName
    $tableName = [string]$table.TableName
    $objectId = [int]$table.ObjectId
    $fullName = (Quote-Name $schemaName) + '.' + (Quote-Name $tableName)

    $columns = Invoke-SqlTable @"
SELECT
    c.column_id,
    c.name AS ColumnName,
    ty.name AS DataType,
    c.max_length,
    c.precision,
    c.scale,
    c.is_nullable,
    c.is_identity,
    CONVERT(BIGINT, ic.seed_value) AS seed_value,
    CONVERT(BIGINT, ic.increment_value) AS increment_value
FROM sys.columns c
INNER JOIN sys.types ty ON ty.user_type_id = c.user_type_id
LEFT JOIN sys.identity_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE c.object_id = @ObjectId
ORDER BY c.column_id;
"@ @{ ObjectId = $objectId }

    $lines.Add("IF OBJECT_ID(N'$fullName', N'U') IS NULL")
    $lines.Add('BEGIN')
    $lines.Add("    CREATE TABLE $fullName")
    $lines.Add('    (')

    for ($i = 0; $i -lt $columns.Rows.Count; $i++) {
        $column = $columns.Rows[$i]
        $typeDefinition = Get-TypeDefinition $column
        $identity = if ([bool]$column.is_identity) { ' IDENTITY(' + $column.seed_value + ',' + $column.increment_value + ')' } else { '' }
        $nullable = if ([bool]$column.is_nullable) { ' NULL' } else { ' NOT NULL' }
        $comma = if ($i -lt $columns.Rows.Count - 1) { ',' } else { '' }
        $lines.Add('        ' + (Quote-Name ([string]$column.ColumnName)) + ' ' + $typeDefinition + $identity + $nullable + $comma)
    }

    $lines.Add('    );')
    $lines.Add('END')
    $lines.Add('GO')
    $lines.Add('')

    $defaults = Invoke-SqlTable @"
SELECT
    dc.name AS ConstraintName,
    c.name AS ColumnName,
    dc.definition AS Definition
FROM sys.default_constraints dc
INNER JOIN sys.columns c ON c.object_id = dc.parent_object_id AND c.column_id = dc.parent_column_id
WHERE dc.parent_object_id = @ObjectId
ORDER BY c.column_id;
"@ @{ ObjectId = $objectId }

    foreach ($default in $defaults.Rows) {
        $constraintName = [string]$default.ConstraintName
        $columnName = [string]$default.ColumnName
        $definition = [string]$default.Definition
        $lines.Add("IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'" + (Escape-Literal $constraintName) + "')")
        $lines.Add('BEGIN')
        $lines.Add("    ALTER TABLE $fullName ADD CONSTRAINT " + (Quote-Name $constraintName) + " DEFAULT $definition FOR " + (Quote-Name $columnName) + ';')
        $lines.Add('END')
        $lines.Add('GO')
        $lines.Add('')
    }

    $keyRows = Invoke-SqlTable @"
SELECT
    kc.name AS ConstraintName,
    kc.type AS ConstraintType,
    i.type_desc AS IndexTypeDesc,
    ic.key_ordinal,
    c.name AS ColumnName,
    ic.is_descending_key
FROM sys.key_constraints kc
INNER JOIN sys.indexes i ON i.object_id = kc.parent_object_id AND i.index_id = kc.unique_index_id
INNER JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
INNER JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
WHERE kc.parent_object_id = @ObjectId
ORDER BY kc.name, ic.key_ordinal;
"@ @{ ObjectId = $objectId }

    foreach ($group in ($keyRows.Rows | Group-Object ConstraintName)) {
        $first = $group.Group[0]
        $constraintName = [string]$first.ConstraintName
        $constraintType = if ([string]$first.ConstraintType -eq 'PK') { 'PRIMARY KEY' } else { 'UNIQUE' }
        $indexType = if ([string]$first.IndexTypeDesc -eq 'CLUSTERED') { 'CLUSTERED' } else { 'NONCLUSTERED' }
        $columnsClause = ($group.Group | Sort-Object key_ordinal | ForEach-Object {
            (Quote-Name ([string]$_.ColumnName)) + $(if ([bool]$_.is_descending_key) { ' DESC' } else { ' ASC' })
        }) -join ', '

        $lines.Add("IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'" + (Escape-Literal $constraintName) + "')")
        $lines.Add('BEGIN')
        $lines.Add("    ALTER TABLE $fullName ADD CONSTRAINT " + (Quote-Name $constraintName) + " $constraintType $indexType ($columnsClause);")
        $lines.Add('END')
        $lines.Add('GO')
        $lines.Add('')
    }

    $checkConstraints = Invoke-SqlTable @"
SELECT
    cc.name AS ConstraintName,
    cc.definition AS Definition
FROM sys.check_constraints cc
WHERE cc.parent_object_id = @ObjectId
ORDER BY cc.name;
"@ @{ ObjectId = $objectId }

    foreach ($check in $checkConstraints.Rows) {
        $constraintName = [string]$check.ConstraintName
        $definition = [string]$check.Definition
        $lines.Add("IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'" + (Escape-Literal $constraintName) + "')")
        $lines.Add('BEGIN')
        $lines.Add("    ALTER TABLE $fullName ADD CONSTRAINT " + (Quote-Name $constraintName) + " CHECK $definition;")
        $lines.Add('END')
        $lines.Add('GO')
        $lines.Add('')
    }
}

$foreignKeyRows = Invoke-SqlTable @"
SELECT
    fk.name AS ForeignKeyName,
    ps.name AS ParentSchema,
    pt.name AS ParentTable,
    rs.name AS RefSchema,
    rt.name AS RefTable,
    pc.name AS ParentColumnName,
    rc.name AS RefColumnName,
    fkc.constraint_column_id,
    fk.delete_referential_action_desc AS OnDeleteAction,
    fk.update_referential_action_desc AS OnUpdateAction
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
INNER JOIN sys.tables pt ON pt.object_id = fk.parent_object_id
INNER JOIN sys.schemas ps ON ps.schema_id = pt.schema_id
INNER JOIN sys.columns pc ON pc.object_id = fkc.parent_object_id AND pc.column_id = fkc.parent_column_id
INNER JOIN sys.tables rt ON rt.object_id = fk.referenced_object_id
INNER JOIN sys.schemas rs ON rs.schema_id = rt.schema_id
INNER JOIN sys.columns rc ON rc.object_id = fkc.referenced_object_id AND rc.column_id = fkc.referenced_column_id
WHERE fk.is_ms_shipped = 0
ORDER BY fk.name, fkc.constraint_column_id;
"@

foreach ($group in ($foreignKeyRows.Rows | Group-Object ForeignKeyName)) {
    $first = $group.Group[0]
    $fkName = [string]$first.ForeignKeyName
    $parentFullName = (Quote-Name ([string]$first.ParentSchema)) + '.' + (Quote-Name ([string]$first.ParentTable))
    $refFullName = (Quote-Name ([string]$first.RefSchema)) + '.' + (Quote-Name ([string]$first.RefTable))
    $parentColumns = ($group.Group | Sort-Object constraint_column_id | ForEach-Object { Quote-Name ([string]$_.ParentColumnName) }) -join ', '
    $refColumns = ($group.Group | Sort-Object constraint_column_id | ForEach-Object { Quote-Name ([string]$_.RefColumnName) }) -join ', '
    $onDelete = if ([string]$first.OnDeleteAction -ne 'NO_ACTION') { ' ON DELETE ' + [string]$first.OnDeleteAction } else { '' }
    $onUpdate = if ([string]$first.OnUpdateAction -ne 'NO_ACTION') { ' ON UPDATE ' + [string]$first.OnUpdateAction } else { '' }

    $lines.Add("IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'" + (Escape-Literal $fkName) + "')")
    $lines.Add('BEGIN')
    $lines.Add("    ALTER TABLE $parentFullName ADD CONSTRAINT " + (Quote-Name $fkName) + " FOREIGN KEY ($parentColumns) REFERENCES $refFullName ($refColumns)$onDelete$onUpdate;")
    $lines.Add('END')
    $lines.Add('GO')
    $lines.Add('')
}

$indexRows = Invoke-SqlTable @"
SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    i.name AS IndexName,
    i.is_unique,
    i.type_desc AS IndexTypeDesc,
    i.filter_definition,
    ic.index_column_id,
    ic.key_ordinal,
    ic.is_descending_key,
    ic.is_included_column,
    c.name AS ColumnName
FROM sys.indexes i
INNER JOIN sys.tables t ON t.object_id = i.object_id
INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
INNER JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
INNER JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
WHERE t.is_ms_shipped = 0
  AND i.index_id > 0
  AND i.is_hypothetical = 0
  AND i.name IS NOT NULL
  AND i.is_primary_key = 0
  AND i.is_unique_constraint = 0
ORDER BY s.name, t.name, i.name, ic.index_column_id;
"@

foreach ($group in ($indexRows.Rows | Group-Object SchemaName, TableName, IndexName)) {
    $first = $group.Group[0]
    $indexName = [string]$first.IndexName
    $tableFullName = (Quote-Name ([string]$first.SchemaName)) + '.' + (Quote-Name ([string]$first.TableName))
    $uniquePrefix = if ([bool]$first.is_unique) { 'UNIQUE ' } else { '' }
    $indexType = if ([string]$first.IndexTypeDesc -eq 'CLUSTERED') { 'CLUSTERED' } else { 'NONCLUSTERED' }
    $keyColumns = Get-IndexColumnList -Rows $group.Group -Included $false
    $includeColumns = Get-IndexColumnList -Rows $group.Group -Included $true
    $includeClause = if ($includeColumns) { ' INCLUDE (' + $includeColumns + ')' } else { '' }
    $filterClause = if ([string]::IsNullOrWhiteSpace([string]$first.filter_definition)) { '' } else { ' WHERE ' + [string]$first.filter_definition }

    $lines.Add("IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'" + (Escape-Literal $indexName) + "' AND object_id = OBJECT_ID(N'$tableFullName'))")
    $lines.Add('BEGIN')
    $lines.Add("    CREATE $uniquePrefix$indexType INDEX " + (Quote-Name $indexName) + " ON $tableFullName ($keyColumns)$includeClause$filterClause;")
    $lines.Add('END')
    $lines.Add('GO')
    $lines.Add('')
}

[System.IO.File]::WriteAllLines($OutputPath, $lines, [System.Text.UTF8Encoding]::new($true))
Write-Host "Deployment script generated: $OutputPath"
