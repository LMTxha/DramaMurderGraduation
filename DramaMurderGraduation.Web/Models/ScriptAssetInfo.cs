namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// ScriptAssetInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class ScriptAssetInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int ScriptId { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string AssetType { get; set; }
        /// <summary>页面或卡片展示标题。</summary>
        public string Title { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string FileName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string RelativePath { get; set; }
        /// <summary>资源或页面访问地址。</summary>
        public string PublicUrl { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string FileExtension { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public long FileSizeBytes { get; set; }
        /// <summary>布尔状态标记。</summary>
        public bool IsPrimary { get; set; }
        /// <summary>排序序号，数值越小越靠前。</summary>
        public int SortOrder { get; set; }
    }
}
