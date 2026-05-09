namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// LiveSessionInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class LiveSessionInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或卡片展示标题。</summary>
        public string Title { get; set; }
        /// <summary>简短摘要文案。</summary>
        public string Summary { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string HostName { get; set; }
        /// <summary>统计数量。</summary>
        public int ViewerCount { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string CoverImage { get; set; }
        /// <summary>资源或页面访问地址。</summary>
        public string RouteUrl { get; set; }
        /// <summary>页面展示文案。</summary>
        public string StatusText { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int HeatScore { get; set; }
    }
}
