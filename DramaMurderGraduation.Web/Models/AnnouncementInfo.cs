using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// AnnouncementInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class AnnouncementInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或卡片展示标题。</summary>
        public string Title { get; set; }
        /// <summary>简短摘要文案。</summary>
        public string Summary { get; set; }
        /// <summary>对应业务日期。</summary>
        public DateTime PublishDate { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsImportant { get; set; }
    }
}
