using System.Collections.Generic;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// ShowcaseSectionInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class ShowcaseSectionInfo
    {
        public ShowcaseSectionInfo()
        {
            Entries = new List<ShowcaseEntryInfo>();
        }

        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string SectionTitle { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string SectionSummary { get; set; }
        /// <summary>业务编码，用于数据库存储或权限判断。</summary>
        public string LayoutCode { get; set; }
        public IList<ShowcaseEntryInfo> Entries { get; }
    }
}
