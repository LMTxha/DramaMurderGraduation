using System;

namespace DramaMurderGraduation.Web.Models
{
    public class FriendChatMessageInfo
    {
        public int Id { get; set; }
        public int SenderUserId { get; set; }
        public string SenderDisplayName { get; set; }
        public string SenderAvatarUrl { get; set; }
        public int ReceiverUserId { get; set; }
        public string ReceiverDisplayName { get; set; }
        public string ReceiverAvatarUrl { get; set; }
        public string MessageType { get; set; }
        public string Content { get; set; }
        public string AttachmentUrl { get; set; }
        public string LocationText { get; set; }
        public bool IsRead { get; set; }
        public bool IsRevoked { get; set; }
        public DateTime? RevokedAt { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
