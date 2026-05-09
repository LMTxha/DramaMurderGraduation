namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// ShowcaseStatInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class ShowcaseStatInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string StatLabel { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string StatValue { get; set; }
    }
}
