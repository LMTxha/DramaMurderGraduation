using System;

namespace DramaMurderGraduation.Web.Models
{
    public class RechargeRequestInfo
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string Username { get; set; }
        public string DisplayName { get; set; }
        public string PaymentMethod { get; set; }
        public decimal Amount { get; set; }
        public string PaymentAccount { get; set; }
        public string PaymentAccountMasked { get; set; }
        public string RequestStatus { get; set; }
        public string ReviewRemark { get; set; }
        public DateTime SubmittedAt { get; set; }
        public DateTime? ReviewedAt { get; set; }
    }
}
