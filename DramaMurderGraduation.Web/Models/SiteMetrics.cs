namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// SiteMetrics 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class SiteMetrics
    {
        /// <summary>统计数量。</summary>
        public int ScriptCount { get; set; }
        /// <summary>统计数量。</summary>
        public int CharacterCount { get; set; }
        /// <summary>统计数量。</summary>
        public int RoomCount { get; set; }
        /// <summary>统计数量。</summary>
        public int ReservationCount { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public decimal AverageRating { get; set; }
    }
}
