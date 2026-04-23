using System;

namespace DramaMurderGraduation.Web.Models
{
    public class FriendMoneyTransferInfo
    {
        public int Id { get; set; }
        public int SenderUserId { get; set; }
        public string SenderDisplayName { get; set; }
        public int ReceiverUserId { get; set; }
        public string ReceiverDisplayName { get; set; }
        public string TransferType { get; set; }
        public decimal Amount { get; set; }
        public string Note { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
