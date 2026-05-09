using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// AchievementInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class AchievementInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或卡片展示标题。</summary>
        public string Title { get; set; }
        /// <summary>详细说明文案。</summary>
        public string Description { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string RarityTag { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int ProgressValue { get; set; }
        /// <summary>统计总量。</summary>
        public int ProgressTotal { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public DateTime? EarnedAt { get; set; }
    }
}
