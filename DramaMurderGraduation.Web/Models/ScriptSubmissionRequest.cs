namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// ScriptSubmissionRequest 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class ScriptSubmissionRequest
    {
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int GenreId { get; set; }
        /// <summary>业务对象名称。</summary>
        public string Name { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Slogan { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string StoryBackground { get; set; }
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
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string AuthorName { get; set; }
    }
}
