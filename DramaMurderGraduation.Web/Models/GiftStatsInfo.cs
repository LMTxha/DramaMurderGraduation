namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// GiftStatsInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class GiftStatsInfo
    {
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int GiftBalance { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int TotalGiftCountSent { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int TotalGiftCountReceived { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int TotalGiftCoinsSent { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int TotalGiftCoinsReceived { get; set; }
    }
}
