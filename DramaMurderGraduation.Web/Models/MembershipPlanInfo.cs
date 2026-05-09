namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// MembershipPlanInfo 数据模型，用于在页面层和仓储层之间传递剧本杀业务数据。
    /// </summary>
    public class MembershipPlanInfo
    {
        /// <summary>业务主键标识。</summary>
        public int Id { get; set; }
        /// <summary>业务对象名称。</summary>
        public string Name { get; set; }
        /// <summary>单价或套餐价格。</summary>
        public decimal Price { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string BillingCycle { get; set; }
        /// <summary>详细说明文案。</summary>
        public string Description { get; set; }
        /// <summary>页面或业务逻辑使用的数据字段。</summary>
        public string BenefitSummary { get; set; }
        /// <summary>页面展示文案。</summary>
        public string HighlightText { get; set; }
    }
}
