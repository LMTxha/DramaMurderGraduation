namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// SiteSettings 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class SiteSettings
    {
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string SiteName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string HeroTitle { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string HeroSubtitle { get; set; }
        /// <summary>页面展示文案。</summary>
        public string WelcomeText { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string AboutTitle { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string AboutContent { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Address { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string BusinessHours { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ContactPhone { get; set; }
        /// <summary>对应业务动作的发生时间。</summary>
        public string ContactWeChat { get; set; }
    }
}
