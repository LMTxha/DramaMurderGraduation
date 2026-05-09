using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// ChallengeInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class ChallengeInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或卡片展示标题。</summary>
        public string Title { get; set; }
        /// <summary>详细说明文案。</summary>
        public string Description { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string CoverImage { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public DateTime EndTime { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string RewardSummary { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string StatusTag { get; set; }
        /// <summary>资源或页面访问地址。</summary>
        public string RouteUrl { get; set; }
    }
}
