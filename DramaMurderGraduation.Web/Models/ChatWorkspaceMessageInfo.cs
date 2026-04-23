using System;

namespace DramaMurderGraduation.Web.Models
{
    public class ChatWorkspaceMessageInfo
    {
        public int Id { get; set; }
        public string ConversationKind { get; set; }
        public int ConversationId { get; set; }
        public int SenderUserId { get; set; }
        public string SenderDisplayName { get; set; }
        public string SenderAvatarUrl { get; set; }
        public bool IsCurrentUser { get; set; }
        public string MessageType { get; set; }
        public string Content { get; set; }
        public string AttachmentUrl { get; set; }
        public string LocationText { get; set; }
        public bool IsRevoked { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
