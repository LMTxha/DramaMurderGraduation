using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// QuickNoteInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class QuickNoteInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>关联的用户主键。</summary>
        public int UserId { get; set; }
        /// <summary>页面或卡片展示标题。</summary>
        public string Title { get; set; }
        /// <summary>正文内容。</summary>
        public string Content { get; set; }
        /// <summary>创建时间。</summary>
        public DateTime CreatedAt { get; set; }
        /// <summary>最近更新时间。</summary>
        public DateTime UpdatedAt { get; set; }
    }
}
