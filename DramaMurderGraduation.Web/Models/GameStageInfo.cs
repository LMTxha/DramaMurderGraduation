using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// GameStageInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class GameStageInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string StageKey { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string StageName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string StageDescription { get; set; }
        /// <summary>排序序号，数值越小越靠前。</summary>
        public int SortOrder { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int DurationMinutes { get; set; }
        /// <summary>页面展示文案。</summary>
        public string StatusText { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsCurrent { get; set; }
        /// <summary>最近更新时间。</summary>
        public DateTime? UpdatedAt { get; set; }
    }
}
