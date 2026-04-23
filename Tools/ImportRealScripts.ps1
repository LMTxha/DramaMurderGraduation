param(
    [Parameter(Mandatory = $true)]
    [string]$SourceRoot,

    [Parameter(Mandatory = $true)]
    [string]$SiteRoot,

    [string]$ConnectionString = 'Data Source=(LocalDB)\MSSQLLocalDB;Initial Catalog=DramaMurderGraduationDb;Integrated Security=True;Connect Timeout=30;MultipleActiveResultSets=True',

    [switch]$RefreshFiles
)

$ErrorActionPreference = 'Stop'

function From-CodePoints([int[]]$points) {
    return -join ($points | ForEach-Object { [char]$_ })
}

function Get-StableSlug([string]$name) {
    $md5 = [System.Security.Cryptography.MD5]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($name)
        $hash = $md5.ComputeHash($bytes)
        return 'script-' + ([System.BitConverter]::ToString($hash).Replace('-', '').Substring(0, 10).ToLowerInvariant())
    }
    finally {
        $md5.Dispose()
    }
}

function Get-AssetType([System.IO.FileInfo]$file, [System.IO.FileInfo]$manual, [System.IO.FileInfo]$cover) {
    $extension = Get-LowerExtension $file

    if ($manual -and $file.FullName -eq $manual.FullName) {
        return 'manual'
    }

    if ($cover -and $file.FullName -eq $cover.FullName) {
        return 'cover'
    }

    switch ($extension) {
        '.pdf' { return 'document' }
        '.docx' { return 'document' }
        '.jpg' { return 'image' }
        '.png' { return 'image' }
        '.mp3' { return 'audio' }
        '.mp4' { return 'video' }
        '.mov' { return 'video' }
        '.xlsx' { return 'spreadsheet' }
        '.rar' { return 'archive' }
        '.txt' { return 'text' }
        default { return 'asset' }
    }
}

function Get-PrimaryManual([System.IO.FileInfo[]]$files) {
    return $files |
        Where-Object { (Get-LowerExtension $_) -in '.pdf', '.docx' } |
        Sort-Object @{ Expression = {
            if ($_.Name -match '主持|手册|开本|须知|真相') { 0 } else { 1 }
        } }, FullName |
        Select-Object -First 1
}

function Get-CoverImage([System.IO.FileInfo[]]$files) {
    return $files |
        Where-Object { (Get-LowerExtension $_) -in '.jpg', '.png' } |
        Sort-Object @{ Expression = {
            if ($_.FullName -match '海报|宣传|封面|立绘') { 0 } else { 1 }
        } }, @{ Expression = 'Length'; Descending = $true }, FullName |
        Select-Object -First 1
}

function Get-LowerExtension($file) {
    if ($null -eq $file) {
        return ''
    }

    $extension = [System.IO.Path]::GetExtension($file.Name)
    if ([string]::IsNullOrEmpty($extension)) {
        return ''
    }

    return $extension.ToLowerInvariant()
}

function Get-DifficultyLabel([System.IO.FileInfo[]]$files) {
    $hasVideo = ($files | Where-Object { (Get-LowerExtension $_) -in '.mp4', '.mov' } | Measure-Object).Count -gt 0
    $hasAudio = ($files | Where-Object { (Get-LowerExtension $_) -eq '.mp3' } | Measure-Object).Count -gt 0

    if ($hasVideo) {
        return '进阶'
    }

    if ($hasAudio) {
        return '沉浸'
    }

    return '本格'
}

function Get-GenreId([string]$name) {
    if ($name -match '怪谈|观白|精神|惊悚|恐怖') {
        return 4
    }

    if ($name -match '红豆|绛夏|花束|离家|月光') {
        return 2
    }

    if ($name -match '破界|双影|机制|阵营') {
        return 3
    }

    return 1
}

function Get-PlayerCount([System.IO.FileInfo[]]$files, [string]$scriptName) {
    $candidateNames = Get-CharacterNames $files $scriptName

    if ($candidateNames.Count -ge 4 -and $candidateNames.Count -le 12) {
        return [Math]::Min([int]$candidateNames.Count, 8)
    }

    return 6
}

function Get-CharacterNames([System.IO.FileInfo[]]$files, [string]$scriptName) {
    $rolePathPattern = '(\\|/)(人物剧本|角色剧本|剧本)(\\|/)'
    $blockedTitlePattern = '主持|手册|真相|线索|证据|开本|须知|流程|复盘|答案|组合|葬喜录|Q&A|勘误|指南|规则|地图|卡牌|通知'

    $roleFiles = $files |
        Where-Object {
            (Get-LowerExtension $_) -in '.pdf', '.docx' -and
            $_.FullName -match $rolePathPattern
        }

    if (($roleFiles | Measure-Object).Count -eq 0) {
        $roleFiles = $files | Where-Object { (Get-LowerExtension $_) -in '.pdf', '.docx' }
    }

    return @($roleFiles |
        ForEach-Object {
            [System.IO.Path]::GetFileNameWithoutExtension($_.Name).Trim() -replace '^\d+\s*[-._、]?\s*', ''
        } |
        Where-Object {
            $_ -and
            $_.Length -le 40 -and
            $_ -ne $scriptName -and
            $_ -notmatch $blockedTitlePattern
        } |
        Select-Object -Unique)
}

function New-DbCommand([System.Data.SqlClient.SqlConnection]$connection, [string]$sql) {
    $command = $connection.CreateCommand()
    $command.CommandText = $sql
    $command.CommandTimeout = 0
    return $command
}

if (-not (Test-Path -LiteralPath $SourceRoot)) {
    throw "SourceRoot not found: $SourceRoot"
}

if (-not (Test-Path -LiteralPath $SiteRoot)) {
    throw "SiteRoot not found: $SiteRoot"
}

$statusOpen = From-CodePoints 24320,25918,39044,32422

$packageRoot = Join-Path $SiteRoot 'ImportedScripts'
if (-not (Test-Path -LiteralPath $packageRoot)) {
    New-Item -ItemType Directory -Path $packageRoot | Out-Null
}

$connection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
$connection.Open()

try {
    $ensureTable = New-DbCommand $connection @"
IF OBJECT_ID('dbo.ScriptAssets', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ScriptAssets
    (
        Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ScriptId INT NOT NULL,
        AssetType NVARCHAR(40) NOT NULL,
        Title NVARCHAR(200) NOT NULL,
        FileName NVARCHAR(260) NOT NULL,
        RelativePath NVARCHAR(500) NOT NULL,
        PublicUrl NVARCHAR(500) NOT NULL,
        FileExtension NVARCHAR(20) NOT NULL,
        FileSizeBytes BIGINT NOT NULL DEFAULT(0),
        IsPrimary BIT NOT NULL DEFAULT(0),
        SortOrder INT NOT NULL DEFAULT(0),
        CreatedAt DATETIME NOT NULL DEFAULT(GETDATE())
    );
    ALTER TABLE dbo.ScriptAssets
    ADD CONSTRAINT FK_ScriptAssets_Scripts FOREIGN KEY (ScriptId) REFERENCES dbo.Scripts(Id) ON DELETE CASCADE;
    CREATE INDEX IX_ScriptAssets_ScriptId ON dbo.ScriptAssets(ScriptId, SortOrder, Id);
END;
"@
    $ensureTable.ExecuteNonQuery() | Out-Null

    $scriptDirs = Get-ChildItem -LiteralPath $SourceRoot -Directory | Sort-Object Name
    $report = New-Object System.Collections.Generic.List[object]

    foreach ($dir in $scriptDirs) {
        $scriptName = $dir.Name.Trim()
        $slug = Get-StableSlug $scriptName
        $targetDir = Join-Path $packageRoot $slug

        if ((Test-Path -LiteralPath $targetDir) -and $RefreshFiles) {
            Remove-Item -LiteralPath $targetDir -Recurse -Force
        }

        if (-not (Test-Path -LiteralPath $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir | Out-Null
            Get-ChildItem -LiteralPath $dir.FullName -Force |
                Copy-Item -Destination $targetDir -Recurse -Force
        }

        $files = Get-ChildItem -LiteralPath $targetDir -Recurse -File | Sort-Object FullName
        $manual = Get-PrimaryManual $files
        $cover = Get-CoverImage $files

        $playerCount = Get-PlayerCount $files $scriptName
        $pdfCount = ($files | Where-Object { (Get-LowerExtension $_) -eq '.pdf' } | Measure-Object).Count
        $imageCount = ($files | Where-Object { (Get-LowerExtension $_) -in '.jpg', '.png' } | Measure-Object).Count
        $mediaCount = ($files | Where-Object { (Get-LowerExtension $_) -in '.mp3', '.mp4', '.mov' } | Measure-Object).Count
        $difficulty = Get-DifficultyLabel $files
        $genreId = Get-GenreId $scriptName
        $duration = if ($difficulty -eq '进阶') { 300 } elseif ($difficulty -eq '沉浸') { 240 } else { 270 }
        $price = if ($difficulty -eq '进阶') { 228.00 } elseif ($difficulty -eq '沉浸') { 208.00 } else { 198.00 }

        $coverUrl = ''
        if ($cover) {
            $coverRelative = $cover.FullName.Substring($targetDir.Length).TrimStart('\').Replace('\', '/')
            $coverUrl = 'ImportedScripts/' + $slug + '/' + $coverRelative
        }

        $manualLabel = if ($manual) { $manual.Name } else { '未检测到主文档' }
        $storyBackground = "本剧本由本地完整资料包导入，已保留 PDF、图片、音频、视频等原始文件，并建立可浏览的资料索引。资料统计：PDF $pdfCount 个，图片 $imageCount 个，音视频 $mediaCount 个。"
        $fullContent = @(
            "本地导入剧本：$scriptName"
            "资料目录：ImportedScripts/$slug"
            "主文档：$manualLabel"
            "文件统计：PDF=$pdfCount / 图片=$imageCount / 音视频=$mediaCount"
            ''
            '原始资料索引：'
        ) + ($files | ForEach-Object {
            $relative = $_.FullName.Substring($targetDir.Length).TrimStart('\')
            "- $relative"
        })
        $manifest = ($fullContent -join [Environment]::NewLine)

        $transaction = $connection.BeginTransaction()
        try {
            $upsert = New-DbCommand $connection @"
DECLARE @ScriptId INT;
SELECT @ScriptId = Id FROM dbo.Scripts WHERE Name = @Name;

IF @ScriptId IS NULL
BEGIN
    INSERT INTO dbo.Scripts
    (
        GenreId, Name, Slogan, StoryBackground, FullScriptContent, CoverImage,
        DurationMinutes, PlayerMin, PlayerMax, Difficulty, Price, IsFeatured, Status,
        AuthorName, CreatorUserId, AuditStatus, AuditComment, SubmittedAt, ReviewedAt,
        KillerCharacterName, TruthSummary
    )
    VALUES
    (
        @GenreId, @Name, @Slogan, @StoryBackground, @FullScriptContent, @CoverImage,
        @DurationMinutes, @PlayerMin, @PlayerMax, @Difficulty, @Price, 0, @Status,
        @AuthorName, NULL, N'Approved', @AuditComment, GETDATE(), GETDATE(),
        N'', N''
    );

    SET @ScriptId = SCOPE_IDENTITY();
END
ELSE
BEGIN
    UPDATE dbo.Scripts
    SET GenreId = @GenreId,
        Slogan = @Slogan,
        StoryBackground = @StoryBackground,
        FullScriptContent = @FullScriptContent,
        CoverImage = @CoverImage,
        DurationMinutes = @DurationMinutes,
        PlayerMin = @PlayerMin,
        PlayerMax = @PlayerMax,
        Difficulty = @Difficulty,
        Price = @Price,
        Status = @Status,
        AuthorName = @AuthorName,
        AuditStatus = N'Approved',
        AuditComment = @AuditComment,
        ReviewedAt = GETDATE()
    WHERE Id = @ScriptId;
END

SELECT @ScriptId;
"@
            $upsert.Transaction = $transaction
            $upsert.Parameters.AddWithValue('@GenreId', $genreId) | Out-Null
            $upsert.Parameters.AddWithValue('@Name', $scriptName) | Out-Null
            $upsert.Parameters.AddWithValue('@Slogan', "本地完整资料包导入，含角色本、主持资料和多媒体素材。") | Out-Null
            $upsert.Parameters.AddWithValue('@StoryBackground', $storyBackground) | Out-Null
            $upsert.Parameters.AddWithValue('@FullScriptContent', $manifest) | Out-Null
            $upsert.Parameters.AddWithValue('@CoverImage', $coverUrl) | Out-Null
            $upsert.Parameters.AddWithValue('@DurationMinutes', $duration) | Out-Null
            $upsert.Parameters.AddWithValue('@PlayerMin', $playerCount) | Out-Null
            $upsert.Parameters.AddWithValue('@PlayerMax', $playerCount) | Out-Null
            $upsert.Parameters.AddWithValue('@Difficulty', $difficulty) | Out-Null
            $upsert.Parameters.AddWithValue('@Price', [decimal]$price) | Out-Null
            $upsert.Parameters.AddWithValue('@Status', $statusOpen) | Out-Null
            $upsert.Parameters.AddWithValue('@AuthorName', '本地资料导入') | Out-Null
            $upsert.Parameters.AddWithValue('@AuditComment', '从本地剧本杀资料库批量导入。') | Out-Null
            $scriptId = [int]$upsert.ExecuteScalar()

            $cleanupAssets = New-DbCommand $connection "DELETE FROM dbo.ScriptAssets WHERE ScriptId = @ScriptId;"
            $cleanupAssets.Transaction = $transaction
            $cleanupAssets.Parameters.AddWithValue('@ScriptId', $scriptId) | Out-Null
            $cleanupAssets.ExecuteNonQuery() | Out-Null

            $cleanupCharacters = New-DbCommand $connection "DELETE FROM dbo.ScriptCharacters WHERE ScriptId = @ScriptId AND Profession IN (@LegacyProfession, @CurrentProfession);"
            $cleanupCharacters.Transaction = $transaction
            $cleanupCharacters.Parameters.AddWithValue('@ScriptId', $scriptId) | Out-Null
            $cleanupCharacters.Parameters.AddWithValue('@LegacyProfession', 'Imported Package') | Out-Null
            $cleanupCharacters.Parameters.AddWithValue('@CurrentProfession', '本地资料导入') | Out-Null
            $cleanupCharacters.ExecuteNonQuery() | Out-Null

            $sort = 1
            foreach ($file in $files) {
                $relative = $file.FullName.Substring($targetDir.Length).TrimStart('\')
                $publicUrl = 'ImportedScripts/' + $slug + '/' + $relative.Replace('\', '/')
                $assetType = Get-AssetType $file $manual $cover
                $isPrimary = ($manual -and $file.FullName -eq $manual.FullName) -or ($cover -and $file.FullName -eq $cover.FullName)

                $insertAsset = New-DbCommand $connection @"
INSERT INTO dbo.ScriptAssets
(ScriptId, AssetType, Title, FileName, RelativePath, PublicUrl, FileExtension, FileSizeBytes, IsPrimary, SortOrder)
VALUES
(@ScriptId, @AssetType, @Title, @FileName, @RelativePath, @PublicUrl, @FileExtension, @FileSizeBytes, @IsPrimary, @SortOrder);
"@
                $insertAsset.Transaction = $transaction
                $insertAsset.Parameters.AddWithValue('@ScriptId', $scriptId) | Out-Null
                $insertAsset.Parameters.AddWithValue('@AssetType', $assetType) | Out-Null
                $insertAsset.Parameters.AddWithValue('@Title', [System.IO.Path]::GetFileNameWithoutExtension($file.Name)) | Out-Null
                $insertAsset.Parameters.AddWithValue('@FileName', $file.Name) | Out-Null
                $insertAsset.Parameters.AddWithValue('@RelativePath', $relative.Replace('\', '/')) | Out-Null
                $insertAsset.Parameters.AddWithValue('@PublicUrl', $publicUrl) | Out-Null
                $insertAsset.Parameters.AddWithValue('@FileExtension', (Get-LowerExtension $file)) | Out-Null
                $insertAsset.Parameters.AddWithValue('@FileSizeBytes', [int64]$file.Length) | Out-Null
                $insertAsset.Parameters.AddWithValue('@IsPrimary', [bool]$isPrimary) | Out-Null
                $insertAsset.Parameters.AddWithValue('@SortOrder', $sort) | Out-Null
                $insertAsset.ExecuteNonQuery() | Out-Null
                $sort++
            }

            $characterNames = Get-CharacterNames $files $scriptName | Select-Object -First 12

            if ($characterNames.Count -lt 4) {
                $characterNames = 1..$playerCount | ForEach-Object { "玩家 $_" }
            }

            foreach ($characterName in $characterNames) {
                $insertCharacter = New-DbCommand $connection @"
INSERT INTO dbo.ScriptCharacters
(ScriptId, Name, Gender, AgeRange, Profession, Personality, SecretLine, Description)
VALUES
(@ScriptId, @Name, @Gender, @AgeRange, @Profession, @Personality, @SecretLine, @Description);
"@
                $insertCharacter.Transaction = $transaction
                $insertCharacter.Parameters.AddWithValue('@ScriptId', $scriptId) | Out-Null
                $insertCharacter.Parameters.AddWithValue('@Name', $characterName) | Out-Null
                $insertCharacter.Parameters.AddWithValue('@Gender', '未标注') | Out-Null
                $insertCharacter.Parameters.AddWithValue('@AgeRange', '详见原始角色本') | Out-Null
                $insertCharacter.Parameters.AddWithValue('@Profession', '本地资料导入') | Out-Null
                $insertCharacter.Parameters.AddWithValue('@Personality', '详见原始角色本') | Out-Null
                $insertCharacter.Parameters.AddWithValue('@SecretLine', '详见原始角色本') | Out-Null
                $insertCharacter.Parameters.AddWithValue('@Description', '角色详细内容保存在已导入的原始剧本资料文件中。') | Out-Null
                $insertCharacter.ExecuteNonQuery() | Out-Null
            }

            $transaction.Commit()
            $report.Add([pscustomobject]@{
                Name = $scriptName
                ScriptId = $scriptId
                Assets = $files.Count
                Characters = $characterNames.Count
                Folder = $targetDir
            }) | Out-Null
        }
        catch {
            $transaction.Rollback()
            throw
        }
    }

    $report | Format-Table -AutoSize | Out-String -Width 240 | Write-Output
}
finally {
    $connection.Close()
    $connection.Dispose()
}
