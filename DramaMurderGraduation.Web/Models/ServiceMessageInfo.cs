using System;

namespace DramaMurderGraduation.Web.Models
{
    public class ServiceMessageInfo
    {
        public int Id { get; set; }
        public string BusinessType { get; set; }
        public int BusinessId { get; set; }
        public int SenderUserId { get; set; }
        public string SenderName { get; set; }
        public string SenderRole { get; set; }
        public string Content { get; set; }
        public bool IsReadByAdmin { get; set; }
        public bool IsReadByUser { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
