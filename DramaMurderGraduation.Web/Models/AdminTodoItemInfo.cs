namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// AdminTodoItemInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class AdminTodoItemInfo
    {
        /// <summary>页面或卡片展示标题。</summary>
        public string Title { get; set; }
        /// <summary>页面展示文案。</summary>
        public string CountText { get; set; }
        /// <summary>简短摘要文案。</summary>
        public string Summary { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string TargetAnchor { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Priority { get; set; }
    }
}
