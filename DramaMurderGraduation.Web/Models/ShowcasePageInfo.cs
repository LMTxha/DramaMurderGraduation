using System.Collections.Generic;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// ShowcasePageInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class ShowcasePageInfo
    {
        public ShowcasePageInfo()
        {
            Stats = new List<ShowcaseStatInfo>();
            Sections = new List<ShowcaseSectionInfo>();
        }

        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string PageKey { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string PageName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string Eyebrow { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string HeroTitle { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string HeroSummary { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string HeroDescription { get; set; }
        /// <summary>页面展示文案。</summary>
        public string BadgeText { get; set; }
        /// <summary>页面展示文案。</summary>
        public string PrimaryActionText { get; set; }
        /// <summary>资源或页面访问地址。</summary>
        public string PrimaryActionUrl { get; set; }
        /// <summary>页面展示文案。</summary>
        public string SecondaryActionText { get; set; }
        /// <summary>资源或页面访问地址。</summary>
        public string SecondaryActionUrl { get; set; }
        public IList<ShowcaseStatInfo> Stats { get; }
        public IList<ShowcaseSectionInfo> Sections { get; }
    }
}
