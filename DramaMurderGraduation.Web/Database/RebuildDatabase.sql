:setvar DatabaseName "DramaMurderGraduationDb"
:setvar DatabaseDirectory "D:\毕业设计\dramamurder\DramaMurderGraduation.Web\App_Data"
:setvar SeedScript "D:\毕业设计\dramamurder\DramaMurderGraduation.Web\Database\DramaMurder.sql"
:setvar MockDataScript "D:\毕业设计\dramamurder\DramaMurderGraduation.Web\Database\SeedMockData.sql"
:on error exit

USE [master];
GO

IF DB_ID(N'$(DatabaseName)') IS NOT NULL
BEGIN
    ALTER DATABASE [$(DatabaseName)] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [$(DatabaseName)];
END
GO

DECLARE @DatabaseDirectory NVARCHAR(4000) = N'$(DatabaseDirectory)';
IF RIGHT(@DatabaseDirectory, 1) IN (N'\', N'/')
BEGIN
    SET @DatabaseDirectory = LEFT(@DatabaseDirectory, LEN(@DatabaseDirectory) - 1);
END;

DECLARE @MdfPath NVARCHAR(4000) = @DatabaseDirectory + N'\$(DatabaseName).mdf';
DECLARE @LdfPath NVARCHAR(4000) = @DatabaseDirectory + N'\$(DatabaseName)_log.ldf';
DECLARE @Sql NVARCHAR(MAX) = N'
CREATE DATABASE [$(DatabaseName)]
ON PRIMARY (
    NAME = N''$(DatabaseName)'',
    FILENAME = N''' + REPLACE(@MdfPath, '''', '''''') + N'''
)
LOG ON (
    NAME = N''$(DatabaseName)_log'',
    FILENAME = N''' + REPLACE(@LdfPath, '''', '''''') + N'''
);';

EXEC sys.sp_executesql @Sql;
GO

USE [$(DatabaseName)];
GO

:r $(SeedScript)
:r $(MockDataScript)
