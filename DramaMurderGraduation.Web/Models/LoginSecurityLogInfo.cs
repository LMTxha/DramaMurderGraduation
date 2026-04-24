using System;

namespace DramaMurderGraduation.Web.Models
{
    public class LoginSecurityLogInfo
    {
        public int Id { get; set; }
        public int? UserId { get; set; }
        public string Username { get; set; }
        public string ResultType { get; set; }
        public string IpAddress { get; set; }
        public string UserAgent { get; set; }
        public string Detail { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
