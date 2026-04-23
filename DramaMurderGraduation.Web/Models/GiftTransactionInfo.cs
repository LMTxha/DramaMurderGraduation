using System;

namespace DramaMurderGraduation.Web.Models
{
    public class GiftTransactionInfo
    {
        public int Id { get; set; }
        public int SenderUserId { get; set; }
        public string SenderDisplayName { get; set; }
        public int ReceiverUserId { get; set; }
        public string ReceiverDisplayName { get; set; }
        public string GiftName { get; set; }
        public string GiftIconText { get; set; }
        public int Quantity { get; set; }
        public int TotalCoins { get; set; }
        public string Summary { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
