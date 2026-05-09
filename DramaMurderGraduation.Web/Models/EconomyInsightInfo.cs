namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// EconomyInsightInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class EconomyInsightInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string CategoryName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string MetricName { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public decimal MetricValue { get; set; }
        /// <summary>页面展示文案。</summary>
        public string TrendText { get; set; }
    }
}
