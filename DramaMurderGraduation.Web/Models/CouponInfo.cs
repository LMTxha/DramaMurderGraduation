using System;

namespace DramaMurderGraduation.Web.Models
{
    public class CouponInfo
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserDisplayName { get; set; }
        public string Username { get; set; }
        public string Title { get; set; }
        public string CouponType { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal MinSpend { get; set; }
        public string Status { get; set; }
        public string Source { get; set; }
        public DateTime IssuedAt { get; set; }
        public DateTime ValidFrom { get; set; }
        public DateTime ValidUntil { get; set; }
        public int? UsedReservationId { get; set; }
        public DateTime? UsedAt { get; set; }
    }
}
