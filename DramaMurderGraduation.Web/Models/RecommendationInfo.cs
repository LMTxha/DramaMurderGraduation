namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// RecommendationInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class RecommendationInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或卡片展示标题。</summary>
        public string Title { get; set; }
        /// <summary>简短摘要文案。</summary>
        public string Summary { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string CoverImage { get; set; }
        /// <summary>统计数量。</summary>
        public int PlayerCount { get; set; }
        /// <summary>统计数量。</summary>
        public int MinPlayerCount { get; set; }
        /// <summary>统计数量。</summary>
        public int MaxPlayerCount { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Difficulty { get; set; }
        /// <summary>评分值。</summary>
        public decimal Rating { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string HighlightTag { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string GenreName { get; set; }
        /// <summary>统计数量。</summary>
        public int UpcomingSessionCount { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public System.DateTime? NextSessionDateTime { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string RecommendationReason { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string SecondaryReason { get; set; }
        /// <summary>资源或页面访问地址。</summary>
        public string DestinationUrl { get; set; }
    }
}
