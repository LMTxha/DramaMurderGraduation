namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// AiResponseInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class AiResponseInfo
    {
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public bool Success { get; set; }
        /// <summary>正文内容。</summary>
        public string Content { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ErrorMessage { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ProviderDisplayName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Model { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public long DurationMs { get; set; }
    }
}