using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using DramaMurderGraduation.Web.Models;

namespace DramaMurderGraduation.Web.Data
{
    /// <summary>
    /// 动态功能展示页仓储。
    /// 多个中文功能页共用 FeatureShowcasePage 基类，页面内容从 ShowcasePages/Sections/Entries/Stats 表读取。
    /// </summary>
    public class ShowcaseRepository
    {
        /// <summary>
        /// 按页面 key 读取完整展示页配置。
        /// pageKey 通常来自 aspx 文件名。
        /// </summary>
        public ShowcasePageInfo GetPage(string pageKey)
        {
            const string pageSql = @"
SELECT TOP 1
    Id,
    PageKey,
    PageName,
    Eyebrow,
    HeroTitle,
    HeroSummary,
    HeroDescription,
    BadgeText,
    PrimaryActionText,
    PrimaryActionUrl,
    SecondaryActionText,
    SecondaryActionUrl
FROM dbo.ShowcasePages
WHERE PageKey = @PageKey;";

            ShowcasePageInfo page = null;

            using (var connection = DbHelper.CreateConnection())
            {
                connection.Open();

                using (var command = new SqlCommand(pageSql, connection))
                {
                    command.Parameters.AddWithValue("@PageKey", pageKey ?? string.Empty);
                    using (var reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            page = new ShowcasePageInfo
                            {
                                Id = GetInt32(reader, "Id"),
                                PageKey = GetString(reader, "PageKey"),
                                PageName = GetString(reader, "PageName"),
                                Eyebrow = GetString(reader, "Eyebrow"),
                                HeroTitle = GetString(reader, "HeroTitle"),
                                HeroSummary = GetString(reader, "HeroSummary"),
                                HeroDescription = GetString(reader, "HeroDescription"),
                                BadgeText = GetString(reader, "BadgeText"),
                                PrimaryActionText = GetString(reader, "PrimaryActionText"),
                                PrimaryActionUrl = GetString(reader, "PrimaryActionUrl"),
                                SecondaryActionText = GetString(reader, "SecondaryActionText"),
                                SecondaryActionUrl = GetString(reader, "SecondaryActionUrl")
                            };
                        }
                    }
                }

                if (page == null)
                {
                    return null;
                }

                using (var statsCommand = new SqlCommand(@"
SELECT Id, StatLabel, StatValue
FROM dbo.ShowcaseStats
WHERE ShowcasePageId = @ShowcasePageId
ORDER BY SortOrder ASC, Id ASC;", connection))
                {
                    statsCommand.Parameters.AddWithValue("@ShowcasePageId", page.Id);
                    using (var reader = statsCommand.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            page.Stats.Add(new ShowcaseStatInfo
                            {
                                Id = GetInt32(reader, "Id"),
                                StatLabel = GetString(reader, "StatLabel"),
                                StatValue = GetString(reader, "StatValue")
                            });
                        }
                    }
                }

                var sectionsById = new Dictionary<int, ShowcaseSectionInfo>();

                using (var sectionsCommand = new SqlCommand(@"
SELECT Id, SectionTitle, SectionSummary, LayoutCode
FROM dbo.ShowcaseSections
WHERE ShowcasePageId = @ShowcasePageId
ORDER BY SortOrder ASC, Id ASC;", connection))
                {
                    sectionsCommand.Parameters.AddWithValue("@ShowcasePageId", page.Id);
                    using (var reader = sectionsCommand.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var section = new ShowcaseSectionInfo
                            {
                                Id = GetInt32(reader, "Id"),
                                SectionTitle = GetString(reader, "SectionTitle"),
                                SectionSummary = GetString(reader, "SectionSummary"),
                                LayoutCode = GetString(reader, "LayoutCode")
                            };

                            page.Sections.Add(section);
                            sectionsById[section.Id] = section;
                        }
                    }
                }

                using (var entriesCommand = new SqlCommand(@"
SELECT
    Id,
    ShowcaseSectionId,
    Title,
    Summary,
    TagText,
    MetaPrimary,
    MetaSecondary,
    MetaTertiary,
    ImageUrl,
    ActionText,
    ActionUrl,
    AccentValue
FROM dbo.ShowcaseEntries
WHERE ShowcaseSectionId IN
(
    SELECT Id
    FROM dbo.ShowcaseSections
    WHERE ShowcasePageId = @ShowcasePageId
)
ORDER BY SortOrder ASC, Id ASC;", connection))
                {
                    entriesCommand.Parameters.AddWithValue("@ShowcasePageId", page.Id);
                    using (var reader = entriesCommand.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var sectionId = GetInt32(reader, "ShowcaseSectionId");
                            if (!sectionsById.ContainsKey(sectionId))
                            {
                                continue;
                            }

                            sectionsById[sectionId].Entries.Add(new ShowcaseEntryInfo
                            {
                                Id = GetInt32(reader, "Id"),
                                Title = GetString(reader, "Title"),
                                Summary = GetString(reader, "Summary"),
                                TagText = GetString(reader, "TagText"),
                                MetaPrimary = GetString(reader, "MetaPrimary"),
                                MetaSecondary = GetString(reader, "MetaSecondary"),
                                MetaTertiary = GetString(reader, "MetaTertiary"),
                                ImageUrl = GetString(reader, "ImageUrl"),
                                ActionText = GetString(reader, "ActionText"),
                                ActionUrl = GetString(reader, "ActionUrl"),
                                AccentValue = GetString(reader, "AccentValue")
                            });
                        }
                    }
                }
            }

            return page;
        }

        /// <summary>读取字符串字段，NULL 转空字符串。</summary>
        private static string GetString(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? string.Empty : Convert.ToString(reader[columnName]);
        }

        /// <summary>读取整数字段。</summary>
        private static int GetInt32(SqlDataReader reader, string columnName)
        {
            return reader[columnName] == DBNull.Value ? 0 : Convert.ToInt32(reader[columnName]);
        }
    }
}
