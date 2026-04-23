using System;

namespace DramaMurderGraduation.Web.Models
{
    public class FriendRequestInfo
    {
        public int Id { get; set; }
        public int SenderUserId { get; set; }
        public string SenderDisplayName { get; set; }
        public string SenderPublicUserCode { get; set; }
        public string SenderAvatarUrl { get; set; }
        public int ReceiverUserId { get; set; }
        public string ReceiverDisplayName { get; set; }
        public string ReceiverPublicUserCode { get; set; }
        public string RequestMessage { get; set; }
        public string Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ReviewedAt { get; set; }
    }
}
