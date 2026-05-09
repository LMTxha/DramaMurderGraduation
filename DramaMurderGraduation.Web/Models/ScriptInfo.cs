namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// ScriptInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class ScriptInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int GenreId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string GenreName { get; set; }
        /// <summary>业务对象名称。</summary>
        public string Name { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Slogan { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string StoryBackground { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string FullScriptContent { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string CoverImage { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int DurationMinutes { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int PlayerMin { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int PlayerMax { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Difficulty { get; set; }
        /// <summary>单价或套餐价格。</summary>
        public decimal Price { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsFeatured { get; set; }
        /// <summary>当前业务状态。</summary>
        public string Status { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string AuthorName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public decimal AverageRating { get; set; }
        /// <summary>统计数量。</summary>
        public int ReviewCount { get; set; }
        /// <summary>统计数量。</summary>
        public int UpcomingSessionCount { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int? CreatorUserId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string CreatorDisplayName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string AuditStatus { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string AuditComment { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public System.DateTime? SubmittedAt { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public System.DateTime? ReviewedAt { get; set; }
    }
}
