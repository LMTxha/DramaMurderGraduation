using System;

namespace DramaMurderGraduation.Web.Models
{
    /// <summary>
    /// 好友私聊消息模型。
    /// 同一条消息可能是普通文本、图片、位置、语音/通话提示或转账消息，所以这里保留了附件、位置和转账字段。
    /// </summary>
    public class FriendChatMessageInfo
    {
        /// <summary>消息 Id。</summary>
        public int Id { get; set; }

        /// <summary>发送人用户 Id。</summary>
        public int SenderUserId { get; set; }

        /// <summary>发送人展示名。</summary>
        public string SenderDisplayName { get; set; }

        /// <summary>发送人头像地址。</summary>
        public string SenderAvatarUrl { get; set; }

        /// <summary>接收人用户 Id。</summary>
        public int ReceiverUserId { get; set; }

        /// <summary>接收人展示名。</summary>
        public string ReceiverDisplayName { get; set; }

        /// <summary>接收人头像地址。</summary>
        public string ReceiverAvatarUrl { get; set; }

        /// <summary>消息类型，例如 Text、Photo、Location、Voice、Transfer。</summary>
        public string MessageType { get; set; }

        /// <summary>文本内容或消息摘要。</summary>
        public string Content { get; set; }

        /// <summary>图片、语音等附件地址。</summary>
        public string AttachmentUrl { get; set; }

        /// <summary>位置消息的地点描述。</summary>
        public string LocationText { get; set; }

        /// <summary>接收人是否已读。</summary>
        public bool IsRead { get; set; }

        /// <summary>消息是否已经撤回。</summary>
        public bool IsRevoked { get; set; }

        /// <summary>撤回时间。</summary>
        public DateTime? RevokedAt { get; set; }

        /// <summary>关联的好友转账 Id，非转账消息为空。</summary>
        public int? MoneyTransferId { get; set; }

        /// <summary>转账状态，例如 Pending、Claimed、Expired。</summary>
        public string MoneyTransferStatus { get; set; }

        /// <summary>收款时间。</summary>
        public DateTime? MoneyClaimedAt { get; set; }

        /// <summary>消息创建时间。</summary>
        public DateTime CreatedAt { get; set; }
    }
}
