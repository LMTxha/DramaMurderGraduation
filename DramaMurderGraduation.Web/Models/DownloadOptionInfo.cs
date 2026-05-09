using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// DownloadOptionInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class DownloadOptionInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }

        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string PlatformName { get; set; }

        /// <summary>业务编码，用于数据库存储或权限判断。</summary>
        public string PlatformCode { get; set; }

        /// <summary>页面展示文案。</summary>
        public string IconText { get; set; }

        /// <summary>页面展示文案。</summary>
        public string VersionText { get; set; }

        /// <summary>简短摘要文案。</summary>
        public string Summary { get; set; }

        /// <summary>资源或页面访问地址。</summary>
        public string DownloadUrl { get; set; }

        /// <summary>对应业务日期。</summary>
        public DateTime ReleaseDate { get; set; }

        /// <summary>排序序号，数值越小越靠前。</summary>
        public int SortOrder { get; set; }
    }
}
