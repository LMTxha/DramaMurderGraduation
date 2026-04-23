using System;

namespace DramaMurderGraduation.Web.Models
{
    public class AiConversationEntryInfo
    {
        public string Role { get; set; }
        public string Content { get; set; }
        public DateTime CreatedAt { get; set; }
        public string ProviderDisplayName { get; set; }
        public string Model { get; set; }
        public bool IsError { get; set; }
    }
}