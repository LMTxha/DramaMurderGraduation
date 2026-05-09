namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// GiftCatalogInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class GiftCatalogInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>业务对象名称。</summary>
        public string Name { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public int PriceInCoins { get; set; }
        /// <summary>页面展示文案。</summary>
        public string IconText { get; set; }
        /// <summary>简短摘要文案。</summary>
        public string Summary { get; set; }
    }
}
