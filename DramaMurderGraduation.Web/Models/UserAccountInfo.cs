using System;

namespace DramaMurderGraduation.Web.Models
{
    public class UserAccountInfo
    {
        public int Id { get; set; }
        public string Username { get; set; }
        public string DisplayName { get; set; }
        public string PublicUserCode { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
        public string RoleCode { get; set; }
        public string ReviewStatus { get; set; }
        public string ReviewRemark { get; set; }
        public decimal Balance { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ReviewedAt { get; set; }
    }
}
