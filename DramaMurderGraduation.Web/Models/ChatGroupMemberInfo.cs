using System;

namespace DramaMurderGraduation.Web.Models
{
    public class ChatGroupMemberInfo
    {
        public int GroupId { get; set; }
        public int UserId { get; set; }
        public string DisplayName { get; set; }
        public string AvatarUrl { get; set; }
        public string PublicUserCode { get; set; }
        public bool IsOwner { get; set; }
        public DateTime JoinedAt { get; set; }
    }
}
