namespace DramaMurderGraduation.Web.Models
{
    public class MembershipPlanInfo
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public decimal Price { get; set; }
        public string BillingCycle { get; set; }
        public string Description { get; set; }
        public string BenefitSummary { get; set; }
        public string HighlightText { get; set; }
    }
}
