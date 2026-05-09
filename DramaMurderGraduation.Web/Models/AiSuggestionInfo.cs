namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// AiSuggestionInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class AiSuggestionInfo
    {
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Category { get; set; }
        /// <summary>页面或卡片展示标题。</summary>
        public string Title { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Prompt { get; set; }
    }
}