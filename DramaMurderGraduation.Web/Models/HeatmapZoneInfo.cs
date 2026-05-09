namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// HeatmapZoneInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class HeatmapZoneInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string ZoneName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int HeatLevel { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string PeakPeriod { get; set; }
        /// <summary>简短摘要文案。</summary>
        public string Summary { get; set; }
    }
}
